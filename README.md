# Sandboxed-OpenCode
Tool to run opencode in a sandboxed environment using `bwrap`.

## Installation

### Prerequisites
- **bubblewrap**: Used for sandboxing.
  - Ubuntu/Debian: `sudo apt install bubblewrap`
  - Arch Linux: `sudo pacman -S bubblewrap`
  - Fedora: `sudo dnf install bubblewrap`
- **opencode**: The AI coding agent.
  - Install via: `curl -fsSL https://opencode.ai/install | bash`

## Usage
1. List any additional files or directories you want to grant access to in `sandbox.conf`.
2. Run the sandbox script:
   ```bash
   ./sandbox.sh [arguments]
   ```

## Setup as Default
To make `opencode` always run sandboxed, add the following alias to your `.bashrc` or `.zshrc`:
```bash
alias opencode='/home/jake/git/Sandboxed-OpenCode/sandbox.sh'
```
Then restart your terminal or run `source ~/.bashrc`.

## Troubleshooting

### `bwrap: setting up uid map: Permission denied`
This occurs when unprivileged user namespaces are disabled or restricted on your system. 

First, try enabling unprivileged user namespaces:
```bash
sudo sysctl -w kernel.unprivileged_userns_clone=1
```

If you are on Ubuntu 24.04 or newer and still see this error, it is likely due to AppArmor restrictions. Run:
```bash
sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
```

To make these changes permanent, add both `kernel.unprivileged_userns_clone=1` and `kernel.apparmor_restrict_unprivileged_userns=0` to `/etc/sysctl.conf`.

