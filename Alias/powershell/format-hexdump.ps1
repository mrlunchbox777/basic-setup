# Pulled from https://pastebin.com/raw/jfZEqtmr
# Created by Thomas Rippon

[CmdletBinding()]
param(
	[string]$file,
	[string[]]$lines,
	$encoding,
	[string]$eol,

	[uint64]$begin=0,
	[uint64]$len=0,
	[uint32]$stride,
	[uint64]$base=0,
	[switch]$header,
	[switch]$reverse,
	[switch]$color,
	[switch]$fit,
	[uint64]$fitsnap=0,

	[Parameter(Mandatory=$false, ValueFromPipeline=$true)]
	[byte[]]$bytes
)
if ( (-not -not $file) + (-not -not $bytes) + (-not -not $lines) -ne 1 ) {
	throw "Only one of file, bytes, or lines can be specified";
}

if ( $stride -and $fit ) {
	throw "Only one of stride or fit can be specified";
}
if ( -not $stride ) {
	$stride = 0x10;
}
if ( $fit -and -not $fitsnap ) {
	$fitsnap = 2;
}


# populate $bytes from either $file or $lines
if ( $file ) {
	$file = [IO.Path]::Combine($pwd, $file);
	$bytes = [IO.File]::ReadAllBytes($file);
}

elseif ( $lines ) {
	if ( -not $eol ) {
		$eol = "`n";
	}
	$string = $lines -join $eol;

	if ( $encoding -and $encoding -is [string] ) {
		$enc = [Text.Encoding]::$encoding;
	}
	elseif ( -not $encoding ) {
		$enc = [Text.Encoding]::UTF8;
	}
	else {
		$enc = $encoding;
	}
	$bytes = $enc.GetBytes($string);
}

if ( $reverse ) {
	$bytes = $bytes.Clone();
	[Array]::Reverse($bytes);
}

if ( -not $len ) {
	[uint64]$end = $bytes.length;
}
else {
	[uint64]$end = $begin + $len;
}

$addr_width = [Math]::ceiling( ("{0:X}" -f ($base + $bytes.length)).length / 2 )*2;

if ( $fitsnap ) {
	# calculate stride based on window width:  remove address width and whitespace separating address, hex, and text.
	# then, about 4 characters used per byte
	$available_width = [Math]::Max(0, [Console]::WindowWidth - $addr_width - 5);
	$stride = [Math]::Floor($available_width / 4);
	if ( $fitsnap -gt 1 -and $stride % $fitsnap ) {
		$stride = [Math]::floor($stride/$fitsnap)*$fitsnap;
	}
}
if ( -not $stride ) {
	throw "window too narrow";

}

$out_enc = [Console]::OutputEncoding;
if ( -not $out_enc.IsSingleByte ) {
	$out_enc = [Text.Encoding]::GetEncoding(1252);
}

$esc = [char]0x1b;
if ( $color ) {
	$hex_fmt  = "$esc[{1}m{0:X2}$esc[0m ";
	$line_fmt = "{0:X$addr_width}  {1}{3} {2}";

	$ansi_seq_of = {
		param(
			[byte]$value
		);

		if ( $value -eq 0x0A -or $value -eq 0x0D ) {
			# carriage return / newline
			return "36;1;40;7";
		}
		elseif ( $value -eq 0x09 ) {
			# tab
			return "33;1";
		}
		elseif ( $value -eq 0 ) {
			# null
			return "38;5;235";
		}
		elseif ( $value -lt 32 -or $value -ge 127 ) {
			# non-printable
			return "38;5;240";
		}
		return "0";
	};
}
else {
	$content_width = $stride*3;
	$ansi_seq_of   = {};
	$hex_fmt       = "{0:X2} ";
	$line_fmt      = "{0:X$addr_width}  {1,-$content_width} {2}";
}

if ( $header ) {
	" "*$addr_width + "  " + ((0..($stride-1)|%{"{0:X2}" -f $_}) -join ' ');
}

$ascii_control = "`a`t`r`n".ToCharArray() + [char[]]@(0,7,8,27) |% {
	$set = new-object Collections.Generic.HashSet[char];
} {
	[void]$set.Add($_);
} {
	$set;
}


for ( ; $begin -lt $end; $begin += $stride ) {
	$slice = $bytes[$begin..($begin+$stride-1)];
	$slice |% {
		$line = '';
		$hexview = '';

	} {
		$ansi = & $ansi_seq_of $_;
		$line += $hex_fmt -f $_, $ansi;
		$char = $out_enc.GetChars($_)[0];

		if ( $ansi ) {
			$hexview += "$esc[$($ansi)m";
		}
		if ( $ascii_control.Contains($char) ) {
			$hexview += '.';
		}
		else {
			$hexview += $char;
		}
		if ( $ansi ) {
			$hexview += "$esc[0m";
		}
	};

	$align = (" "*(($stride-$slice.Count)*3));
	$line_fmt -f ($begin+$base),$line,$hexview,$align;
}
