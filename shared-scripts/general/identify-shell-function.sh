#! /usr/bin/env bash

# run identify shell function
identify-shell-function() {
  local shell=$(ps -o args= -p "$$" | awk '{print $1}' | awk -F '/' '{print $NF}')
  if [ -z "$shell" ]; then
    echo "bash version - $BASH_VERSION"
    echo "zsh version - $ZSH_VERSION"
    if [ ! -z "$BASH_VERSION" ]; then
      shell="bash"
    fi
    if [ ! -z "$ZSH_VERSION" ]; then
      shell="zsh"
    fi
  fi
  echo "$shell"
}
