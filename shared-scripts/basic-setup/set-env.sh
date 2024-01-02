# TODO: add a description of this file

# NOTE: don't run environment-validation here, it could cause a loop

#
# Error handling (off instead of on)
#
SET_E_AFTER=true
if [[ $- =~ e ]]; then
	set +e
else
	SET_E_AFTER=false
fi

# set e to the right value after running the script
function update_e {
	if [ "$SET_E_AFTER" == "true" ]; then
		set -e
	fi
}

ORIGINAL_ENV_FILE="${HOME}/.basic-setup/.env"
if (( $VERBOSITY > 0 )); then
	echo "Attempting .env file load with..." >&2
	echo "BASIC_SETUP_SHOULD_SKIP_ENV_FILE=$BASIC_SETUP_SHOULD_SKIP_ENV_FILE" >&2
	echo "ORIGINAL_ENV_FILE=$ORIGINAL_ENV_FILE" >&2
	echo "BASIC_SETUP_ENV_FILE=$BASIC_SETUP_ENV_FILE" >&2
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
				update_e && exit 1
			else
				(( $VERBOSITY > 0 )) && echo "Using custom env file at $BASIC_SETUP_ENV_FILE..." >&2
			fi
		fi
	# otherwise use the original env file if it exists
	elif [ -f "$ORIGINAL_ENV_FILE" ]; then
		export BASIC_SETUP_ENV_FILE="$ORIGINAL_ENV_FILE"
	fi
	# load the env file if it exists
	if [ ! -z "$BASIC_SETUP_ENV_FILE" ] && [ -f "$BASIC_SETUP_ENV_FILE" ]; then
		# if custom, copy the env file to the expected location
		if [ "$BASIC_SETUP_ENV_FILE" != "$ORIGINAL_ENV_FILE" ]; then
			(( $VERBOSITY > 0 )) && echo "Copying $BASIC_SETUP_ENV_FILE to $ORIGINAL_ENV_FILE..." >&2
			mkdir -p "${HOME}/.basic-setup"
			cp "$BASIC_SETUP_ENV_FILE" "$ORIGINAL_ENV_FILE"
		fi
		(( $VERBOSITY > 0 )) && echo "Loading environment variables from $ORIGINAL_ENV_FILE..." >&2
		# load the env file
		vals=($(cat $ORIGINAL_ENV_FILE | sed 's/#.*//g' | xargs))
		if [ ! -z "$vals" ]; then
			(( $VERBOSITY > 0 )) && echo "Setting environment variables..." >&2
			(( $VERBOSITY > 1 )) && echo "${vals[@]}" >&2
		fi
		export "${vals[@]}"
		(( $VERBOSITY > 1 )) && echo "showing the test value (\\\`TEST=\$TEST\\\`)- \`TEST=$TEST\`" >&2
	else
		(( $VERBOSITY > 0 )) && echo "No environment file found at $BASIC_SETUP_ENV_FILE..." >&2
	fi
fi

update_e
