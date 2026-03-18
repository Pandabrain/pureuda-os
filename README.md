![Pureuda OS Watermark](pureuda-os-watermark.png)

# 푸르다 OS

푸르다 OS (Pureuda OS) is my personal custom Linux image, built with [BlueBuild](https://blue-build.org) using Fedora Atomic Cosmic as a base.

> [!IMPORTANT]
> This is my personal image and is primarily intended for my own use. It contains a large amount of pre-installed software and configurations that may not be suitable for everyone and are subject to change at any time without notice.

## 🍴 Credits & Fork Information

This project is a fork of **[Origami Linux](https://origami.wf)**. Thanks to the Origami Linux team for their groundwork.

If you are looking for a properly maintained and built Linux distribution for general use, I highly recommend visiting the **[Origami Linux website](https://origami.wf)** and giving their OS a try!

## 🚀 How to Use

You can either download the iso from releases or rebase to this image from an existing bootc/rpm-ostree image.
Note that some system defaults may not be used if rebasing from a different OS as some user config might override Pureuda OS defaults.
Starting with the ISO is therefore highly recommended to get the full experience.

### Via bootc (Recommended when rebasing)

To rebase your system using `bootc`, run the following command:

```bash
sudo bootc switch ghcr.io/pandabrain/pureuda-os:latest
```

### Via rpm-ostree

Alternatively, you can use `rpm-ostree`:

Rebase to the unsigned image first to install signing keys (if applicable)
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/pandabrain/pureuda-os:latest
```
When booted into the unverified image, rebase to the signed image:
```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/pandabrain/pureuda-os:latest
```