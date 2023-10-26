ORIGINAL_ENV_FILE="${HOME}/.basic-setup/.env"
if (( $VERBOSITY > 0 )); then
	echo "Attempting .env file load with..."
	echo "BASIC_SETUP_SHOULD_SKIP_ENV_FILE=$BASIC_SETUP_SHOULD_SKIP_ENV_FILE"
	echo "ORIGINAL_ENV_FILE=$ORIGINAL_ENV_FILE"
	echo "BASIC_SETUP_ENV_FILE=$BASIC_SETUP_ENV_FILE"
fi

# skip if asked to
if [ "$BASIC_SETUP_SHOULD_SKIP_ENV_FILE" != "true" ]; then
	# use custom env file if asked to
	if [ ! -z "$BASIC_SETUP_ENV_FILE" ]; then
		# skip if custom file is the same as the original
		if [ "$BASIC_SETUP_ENV_FILE" != "$ORIGINAL_ENV_FILE" ]; then
			# ensure custom file exists
			if [ ! -f "$BASIC_SETUP_ENV_FILE" ]; then
				echo "Error: Environment file expected, but not found at $BASIC_SETUP_ENV_FILE" >&2
				exit 1
			else
				(( $VERBOSITY > 0 )) && echo "Using custom env file at $BASIC_SETUP_ENV_FILE..."
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
			(( $VERBOSITY > 0 )) && echo "Copying $BASIC_SETUP_ENV_FILE to $ORIGINAL_ENV_FILE..."
			mkdir -p "${HOME}/.basic-setup"
			cp "$BASIC_SETUP_ENV_FILE" "$ORIGINAL_ENV_FILE"
		fi
		(( $VERBOSITY > 0 )) && echo "Loading environment variables from $ORIGINAL_ENV_FILE..."
		# load the env file
		vals=($(cat $ORIGINAL_ENV_FILE | sed 's/#.*//g' | xargs))
		if [ ! -z "$vals" ]; then
			(( $VERBOSITY > 0 )) && echo "Setting environment variables..."
			(( $VERBOSITY > 1 )) && echo "${vals[@]}"
		fi
		export "${vals[@]}"
		(( $VERBOSITY > 1 )) && echo "showing the test value (\\\`TEST=\$TEST\\\`)- \`TEST=$TEST\`"
	else
		(( $VERBOSITY > 0 )) && echo "No environment file found at $BASIC_SETUP_ENV_FILE..."
	fi
fi
