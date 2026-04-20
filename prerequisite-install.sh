ARCH="$(uname -m)"
release_url="https://github.com/firecracker-microvm/firecracker/releases"

latest_version=$(basename $(curl -fsSLI -o /dev/null -w  %{url_effective} ${release_url}/latest))

CI_VERSION=${latest_version%.*}

latest_kernel_key=$(curl "http://spec.ccfc.min.s3.amazonaws.com/?prefix=firecracker-ci/$CI_VERSION/$ARCH/vmlinux-&list-type=2" \
    | grep -oP "(?<=<Key>)(firecracker-ci/$CI_VERSION/$ARCH/vmlinux-[0-9]+\.[0-9]+\.[0-9]{1,3})(?=</Key>)" \
    | sort -V | tail -1)

latest_ubuntu_key=$(curl "http://spec.ccfc.min.s3.amazonaws.com/?prefix=firecracker-ci/$CI_VERSION/$ARCH/ubuntu-&list-type=2" \
    | grep -oP "(?<=<Key>)(firecracker-ci/$CI_VERSION/$ARCH/ubuntu-[0-9]+\.[0-9]+\.squashfs)(?=</Key>)" \
    | sort -V | tail -1)


kernel_filename=$(basename $latest_kernel_key)
ubuntu_version=$(basename $latest_ubuntu_key .squashfs | grep -oE '[0-9]+\.[0-9]+')

# Download kernel if not already present
if [[ -f "$kernel_filename" ]]; then
  echo "Skipping kernel download, already exists: $kernel_filename"
else
  echo "Downloading kernel: $kernel_filename"
  # Download a linux kernel binary
  wget "https://s3.amazonaws.com/spec.ccfc.min/${latest_kernel_key}"
fi
 
# Download rootfs 
wget -O ubuntu-$ubuntu_version.squashfs.upstream "https://s3.amazonaws.com/spec.ccfc.min/$latest_ubuntu_key"

# The rootfs in AWS CI doesn't contain SSH keys to connect to the VM
unsquashfs ubuntu-$ubuntu_version.squashfs.upstream
ssh-keygen -f id_rsa -N ""

cp -v id_rsa.pub squashfs-root/root/.ssh/authorized_keys
mv -v id_rsa ./ubuntu-$ubuntu_version.id_rsa

# create ext4 filesystem image
sudo chown -R root:root squashfs-root
truncate -s 1G ubuntu-$ubuntu_version.ext4
sudo mkfs.ext4 -d squashfs-root -F ubuntu-$ubuntu_version.ext4

# Firecracker Binary download + verification via SHA256

ARCHIVE="firecracker-${latest_version}-${ARCH}.tgz"
SHA256="${ARCHIVE}.sha256.txt"

# Verify required files exist
if [[ ! -f "$ARCHIVE" ]]; then
  echo "Error: Archive not found: $ARCHIVE" >&2
  curl -L ${release_url}/download/${latest_version}/firecracker-${latest_version}-${ARCH}.tgz | tar -xz
  curl -L ${release_url}/download/${latest_version}/firecracker-${latest_version}-${ARCH}.tgz.sha256.txt
fi
 
if [[ ! -f "$SHA_FILE" ]]; then
  echo "Error: SHA256 file not found: $SHA_FILE" >&2
  exit 1
fi

# Verify SHA256 checksum
echo "Verifying SHA256 checksum..."
if command -v sha256sum &>/dev/null; then
  EXPECTED="$(awk '{print $1}' "$SHA_FILE")"
  ACTUAL="$(sha256sum "$ARCHIVE" | awk '{print $1}')"
elif command -v shasum &>/dev/null; then
  EXPECTED="$(awk '{print $1}' "$SHA_FILE")"
  ACTUAL="$(shasum -a 256 "$ARCHIVE" | awk '{print $1}')"
else
  echo "Error: No SHA256 utility found (sha256sum or shasum required)." >&2
  exit 1
fi
 
if [[ "$ACTUAL" != "$EXPECTED" ]]; then
  echo "Error: SHA256 mismatch!" >&2
  echo "  Expected: $EXPECTED" >&2
  echo "  Actual:   $ACTUAL" >&2
  exit 1
fi
 
echo "SHA256 verified successfully."
 
# Extract archive
echo "Extracting $ARCHIVE..."
tar -xzf "$ARCHIVE"
echo "Done."