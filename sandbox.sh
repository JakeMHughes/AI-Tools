#!/bin/bash

# Configuration
CONFIG_FILE="sandbox.conf"
Opencode_BIN=$(which opencode)

if [[ -z "$Opencode_BIN" ]]; then
    echo "Error: opencode binary not found in PATH"
    exit 1
fi

# Start bwrap command
# We use --tmpfs for home to ensure a clean environment
BWRAP_CMD="bwrap"

# Basic system requirements
BWRAP_CMD+=" --ro-bind /usr /usr"
BWRAP_CMD+=" --ro-bind /lib /lib"
BWRAP_CMD+=" --ro-bind /lib64 /lib64"
BWRAP_CMD+=" --ro-bind /bin /bin"
BWRAP_CMD+=" --ro-bind /sbin /sbin"
BWRAP_CMD+=" --ro-bind /etc /etc"
BWRAP_CMD+=" --dir /tmp"
BWRAP_CMD+=" --proc /proc"
BWRAP_CMD+=" --dev /dev"

# Setup a virtual home directory
BWRAP_CMD+=" --tmpfs /home/$USER"

# Bind the opencode configuration (read-only)
BWRAP_CMD+=" --ro-bind ~/.config/opencode /home/$USER/.config/opencode"
BWRAP_CMD+=" --ro-bind ~/.opencode /home/$USER/.opencode"

# Bind the current working directory
BWRAP_CMD+=" --bind \"$PWD\" \"$PWD\""

# Share permissions
BWRAP_CMD+=" --share-net"

# Bind extra paths from sandbox.conf
if [[ -f "$CONFIG_FILE" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        
        # Expand tilde to home directory
        eval expanded_path="$line"
        
        BWRAP_CMD+=" --bind \"$expanded_path\" \"$expanded_path\""
    done < "$CONFIG_FILE"
fi

# Execute the opencode binary
eval "$BWRAP_CMD $Opencode_BIN \"\$@\""
