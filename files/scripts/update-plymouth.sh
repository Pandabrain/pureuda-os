#!/usr/bin/env bash
set -exuo pipefail

echo "Updating Plymouth watermark in initramfs..."

# Verify if the watermark file exists at the correct location
if [ -f "/usr/share/plymouth/themes/spinner/watermark.png" ]; then
    echo "Found watermark.png, rebuilding initramfs with dracut..."
    # Rebuild initramfs to include the new watermark
    # The kernel version used for dracut will be the one currently installed in the image
    # We use --force to overwrite the existing initramfs
    # In some ublue-based builds, we use the build-provided script or call dracut directly
    # Here we use dracut -v -f /lib/modules/$(ls /lib/modules | head -n1)/initramfs.img $(ls /lib/modules | head -n1)
    # Set default theme to spinner just in case
    plymouth-set-default-theme spinner
    
    KERNEL_VERSION=$(ls /lib/modules | head -n1)
    if [ -n "$KERNEL_VERSION" ]; then
        dracut -v -f --kver "$KERNEL_VERSION"
    else
        echo "Warning: Could not determine kernel version, skipping dracut update."
    fi
else
    echo "Warning: /usr/share/plymouth/themes/spinner/watermark.png not found. Is it placed correctly?"
fi
