# Firecracker Tooling Setup
## Initialization
The Repository Contains Firecracker Releases for both ARM and x86_64 architecture. The installation script will detect which architecture your system runs and unzip accordingly. Note that prerequisite guest OS image is provided in repo. Squashfs needs to be installed via the script as its too large for a repo.

## [prerequisite_install.sh](./prerequisite_install.sh)
A shell script that setups a local [Firecracker](https://github.com/firecracker-microvm/firecracker) microVM environment for the current system architecture.
### What it does
- Detects system architecture (`uname -m`) and resolves the latest Firecracker release version from GitHub
- Downloads the latest `vmlinux` kernel image from the Firecracker CI S3 bucket — skipped if already present
- Downloads the latest Ubuntu rootfs `.squashfs` from S3 — skipped if already present
- Injects a freshly generated SSH keypair into the rootfs so the VM is accessible over SSH
- Builds a 1 GB ext4 filesystem image populated from the extracted rootfs
- Downloads and verifies the Firecracker binary tarball via SHA256 checksum, then extracts it
### Dependencies
 
`curl`, `wget`, `unsquashfs`, `ssh-keygen`, `mkfs.ext4`, `sha256sum` / `shasum`, `tar`, `sudo`
 
> **Note:** `sudo` is required for the `chown` and `mkfs.ext4` steps.

## [verify_install.sh](./verify_install.sh)
A shell script that verifies the setup from prerequisite-install.sh and renames firecracker and jailer binaries to simply 'firecracker' and 'jailer' for future shell scripting.
## [run_firecracker.sh](./run_firecracker.sh)
A shell script that clears linux socket from a prior use and runs the firecracker binary. Run it parallel, in a separate terminal from lambda_orchestrator.sh [[./lambda_orchestrator.sh]]
## [lambda_orchestrator.sh](./lambda_orchestrator.sh)
A shell script that setups the guest and host os step by step and deploys the provided lambda function and the http runtime for communication to the guest os in firecracker.
- Stage 1: Host Network & TAP setup
- Stage 2: VM & TAP Configuration
- Stage 3: VM Instance Initialization
- Stage 4: Guest OS Network Configuration
- Stage 5: Function Deployment
- Stage 6: Invoke Function using POST
> Currently, only stages 1-3 are completed. Further tests are pending and expected to be completed by April 25th.