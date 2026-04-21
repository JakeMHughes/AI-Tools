#!/bin/bash

# Configuration
CONFIG_FILE="sandbox.conf"
Opencode_BIN=$(which opencode)

if [[ -z "$Opencode_BIN" ]]; then
    echo "Error: opencode binary not found in PATH"
    exit 1
fi

# Handle optional parameters
KUBE_BIND=false
NPM_BIND=false
FILTERED_ARGS=()
for arg in "$@"; do
  echo "Processing: $arg"
    if [[ "$arg" == "--kube" ]]; then
        KUBE_BIND=true
    elif [[ "$arg" == "--npm" ]]; then
        NPM_BIND=true
    else
        FILTERED_ARGS+=("$arg")
    fi
done

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
BWRAP_CMD+=" --ro-bind /run /run"
BWRAP_CMD+=" --dir /tmp"
BWRAP_CMD+=" --proc /proc"
BWRAP_CMD+=" --dev /dev"

# Setup a virtual home directory
BWRAP_CMD+=" --tmpfs /home/$USER"


# Bind the opencode configuration (read-only)
BWRAP_CMD+=" --ro-bind ~/.config/opencode /home/$USER/.config/opencode"
BWRAP_CMD+=" --bind ~/.opencode /home/$USER/.opencode"
BWRAP_CMD+=" --bind ~/.local/share/opencode /home/$USER/.local/share/opencode"
BWRAP_CMD+=" --bind ~/.local/state/opencode /home/$USER/.local/state/opencode"

# Bind kube config if requested and exists
if [[ "$KUBE_BIND" == true && -d ~/.kube ]]; then
    echo "Adding Kubernetes access"
    BWRAP_CMD+=" --ro-bind ~/.kube /home/$USER/.kube"
fi

# Bind NPM config if requested
if [[ "$NPM_BIND" == true ]]; then
    echo "Adding NPM access"
    [[ -d /usr/local/lib/node_modules ]] && BWRAP_CMD+=" --ro-bind /usr/local/lib/node_modules /usr/local/lib/node_modules"
    [[ -d /usr/lib/node_modules ]] && BWRAP_CMD+=" --ro-bind /usr/lib/node_modules /usr/lib/node_modules"
    [[ -d ~/.npm ]] && BWRAP_CMD+=" --ro-bind ~/.npm /home/$USER/.npm"
    [[ -f ~/.npmrc ]] && BWRAP_CMD+=" --ro-bind ~/.npmrc /home/$USER/.npmrc"
fi


# Bind the current working directory
BWRAP_CMD+=" --bind \"$PWD\" \"$PWD\""

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
eval "$BWRAP_CMD $Opencode_BIN" "${FILTERED_ARGS[@]}"
# Use below command for viewing whas bound to the sandbox
#eval "$BWRAP_CMD bash"
