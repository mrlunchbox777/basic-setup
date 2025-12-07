#export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true

# change gems home to a local directory, but allow this to be overridden
# by an existing environment variable
if [ -z "$GEM_HOME" ]; then
	export GEM_HOME="$HOME/.gems"
	export PATH="$GEM_HOME/bin:$PATH"
fi

# if ruby is installed via brew, add its location to the PATH
if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
	export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
fi

# if openjdk is installed via brew, set JAVA_HOME and related variables
if [ -d "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk" ]; then
	export JAVA_HOME="/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
	# create a symlink for macOS to find the JDK if it's not already there
	if [ ! -d "/Library/Java/JavaVirtualMachines/openjdk.jdk" ]; then
		sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
	fi
	# add openjdk to PATH and set CPPFLAGS
	export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
	export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
fi
