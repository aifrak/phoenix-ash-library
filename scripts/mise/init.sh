#!/bin/bash

printf "%s\n" "-- Initializing mise --"

# `mise run` is experimental.
mise settings set experimental true

MISE_ENV=${MISE_ENV:-local}

# Add "--shims" when it is not interactive mode
# see: https://mise.jdx.dev/cli/activate.html
# [[ $- == *i* ]] && shims_flag="--shims" || shims_flag=""

# Initializes mise in the current shell session
current_shell=$(basename "$SHELL")
eval "$(mise activate $shims_flag $current_shell)"
