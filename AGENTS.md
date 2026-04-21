# Sandboxed-OpenCode Overview

This project provides a mechanism to run the `opencode` AI coding agent within a restricted environment using `bubblewrap` (`bwrap`).

## Project Structure

- `sandbox.sh`: The main entry point. It configures the sandbox environment, manages mount points, and executes the `opencode` binary.
- `sandbox.conf`: A configuration file used to specify additional host paths that should be bound into the sandbox.
- `README.md`: General installation and usage instructions.

## Key Features

- **Isolation**: Uses `bwrap` to ensure `opencode` only has access to the files and directories explicitly granted.
- **Virtual Home**: Sets up a temporary home directory to prevent accidental modification of the host's home directory.
- **Optional Access**: Supports flags like `--kube` (for Kubernetes config) and `--npm` (for Node.js modules and config) to provide selective access to system resources.
- **Customizable**: Allows users to extend the sandbox's access via `sandbox.conf`.
