# load environment variables
ORIGINAL_ENV_FILE="${HOME}/.basic-setup/.env"

# skip if asked to
if [ "$BASIC_SETUP_SHOULD_SKIP_ENV_FILE" == "false" ]; then
	# use custom env file if asked to
	if [ ! -z "$BASIC_SETUP_ENV_FILE" ]; then
		# skip if custom file is the same as the original
		if [ "$BASIC_SETUP_ENV_FILE" != "$ORIGINAL_ENV_FILE" ]; then
			# ensure custom file exists
			if [ ! -f "$BASIC_SETUP_ENV_FILE" ]; then
				echo "Error: Environment file expected, but not found at $BASIC_SETUP_ENV_FILE" >&2
				exit 1
			else
				export BASIC_SETUP_ENV_FILE="$ORIGINAL_ENV_FILE"
			fi
		fi
	# otherwise use the original env file if it exists
	elif [ -f "$ORIGINAL_ENV_FILE" ]; then
		export BASIC_SETUP_ENV_FILE="$ORIGINAL_ENV_FILE"
	fi
	# load the env file if it exists
	if [ -f "$BASIC_SETUP_ENV_FILE" ]; then
		# if custom, copy the env file to the expected location
		if [ "$BASIC_SETUP_ENV_FILE" != "$ORIGINAL_ENV_FILE" ]; then
			mkdir -p "${HOME}/.basic-setup"
			cp "$BASIC_SETUP_ENV_FILE" "$ORIGINAL_ENV_FILE"
		fi
		# load the env file
		export $(cat $ORIGINAL_ENV_FILE | sed 's/#.*//g' | xargs)
	fi
fi
