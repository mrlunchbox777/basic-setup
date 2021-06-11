function start-sudo([String]$sudoArgs){ powershell Start-Process -FilePath "$sudoArgs" -Verb runAs }
Set-Alias sudo "start-sudo"
function start-sudosu{ Start-Process powershell -ArgumentList {sudo powershell}; exit; }
Set-Alias sudosu "start-sudosu"

# function sudo() {
#     if ( $args.Length -eq 0 ) {
#         throw "sudo: No arguments";
#     }

#     if ($args.Length -eq 1) {
#         start-process `
#             -Wait `
#             -verb runAs `
#             -WorkingDirectory $pwd `
#             $args[0];
#     }
#     else {
#         start-process `
#             -Wait `
#             -verb runAs `
#             -WorkingDirectory $pwd `
#             $args[0] `
#             -ArgumentList $args[1..($args.Length-1)];
#     }
# }

# function ps-sudo() {
#     $cmdArgs = @("cd `"$pwd`"; ") + $args;
#     $block = "$([scriptblock]::create($cmdArgs))";   # ?
#     sudo powershell -command $block;
# }
