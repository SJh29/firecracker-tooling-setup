# Verify everything was correctly set up and print versions
echo
echo "The following files were downloaded and set up:"
KERNEL=$(ls vmlinux-* | tail -1)
[ -f $KERNEL ] && echo "Kernel: $KERNEL" || echo "ERROR: Kernel $KERNEL does not exist"
ROOTFS=$(ls *.ext4 | tail -1)
e2fsck -fn $ROOTFS &>/dev/null && echo "Rootfs: $ROOTFS" || echo "ERROR: $ROOTFS is not a valid ext4 fs"
KEY_NAME=$(ls *.id_rsa | tail -1)
[ -f $KEY_NAME ] && echo "SSH Key: $KEY_NAME" || echo "ERROR: Key $KEY_NAME does not exist" 



ARCH="$(uname -m)"
release_url="https://github.com/firecracker-microvm/firecracker/releases"
latest_version=$(basename $(curl -fsSLI -o /dev/null -w  %{url_effective} ${release_url}/latest))

folder="release-${latest_version}-${ARCH}"
FIRECRACKER="${folder}/firecracker-${latest_version}-${ARCH}"
JAILER="${folder}/jailer-${latest_version}-${ARCH}"

if [[ -f "$FIRECRACKER" ]]; then
  echo "Firecracker Found: '$latest_version'"
else
  echo "Error: Firecracker not found in '$folder'." >&2
  exit 1
fi

if [[ -f "$JAILER" ]]; then
  echo "Jailer Found."
else
  echo "Error: Firecracker not found in '$folder'." >&2
  exit 1
fi

# Rename Binaries
# Rename the binary to "firecracker"
mv release-${latest}-${ARCH}/firecracker-${latest}-${ARCH} firecracker
echo "firecracker binary renamed to 'firecracker'"

# Rename the binary to "jailer"
mv release-${latest}-${ARCH}/jailer-${latest}-${ARCH} jailer
echo "jailer binary renamed to 'jailer'"

echo '******'
echo "Firecracker installation verified"
