#export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true

# change gems home to a local directory, but allow this to be overridden
# by an existing environment variable
if [ -z "$GEM_HOME" ]; then
	export GEM_HOME="$HOME/.gems"
	export PATH="$GEM_HOME/bin:$PATH"
fi

# if ruby is installed via brew, add its location to the PATH
if command -v brew &> /dev/null; then
	BREW_PREFIX="$(brew --prefix)"
	if [ -d "$BREW_PREFIX/opt/ruby/bin" ]; then
		export PATH="$BREW_PREFIX/opt/ruby/bin:$PATH"
	fi
fi

# if openjdk is installed via brew, set JAVA_HOME and related variables
if command -v brew >/dev/null 2>&1; then
	OPENJDK_PREFIX="$(brew --prefix openjdk 2>/dev/null)"
	if [ -n "$OPENJDK_PREFIX" ] && [ -d "$OPENJDK_PREFIX/libexec/openjdk.jdk" ]; then
		export JAVA_HOME="$OPENJDK_PREFIX/libexec/openjdk.jdk/Contents/Home"
		# create a symlink for macOS to find the JDK if it's not already there
		if [ ! -d "/Library/Java/JavaVirtualMachines/openjdk.jdk" ]; then
			sudo ln -sfn "$OPENJDK_PREFIX/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk.jdk
		fi
		# add openjdk to PATH and set CPPFLAGS
		export PATH="$OPENJDK_PREFIX/bin:$PATH"
		export CPPFLAGS="-I$OPENJDK_PREFIX/include"
	fi
fi
