# pureuda-os & pureuda-os-gaming &nbsp; [![bluebuild build badge](https://github.com/pandabrain/pureuda-os/actions/workflows/build.yml/badge.svg)](https://github.com/pandabrain/pureuda-os/actions/workflows/build.yml)

This repository builds two separate OS images:
- **pureuda-os**: Based on Aurora DX
- **pureuda-os-gaming**: Based on Bazzite DX

See the [BlueBuild docs](https://blue-build.org/how-to/setup/) for quick setup instructions for setting up your own repository based on this template.

## Installation

> [!WARNING]  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build:

### pureuda-os (Aurora based)

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/pandabrain/pureuda-os:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/pandabrain/pureuda-os:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

### pureuda-os-gaming (Bazzite based)

- First rebase to the unsigned image:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/pandabrain/pureuda-os-gaming:latest
  ```
- Reboot:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/pandabrain/pureuda-os-gaming:latest
  ```
- Reboot again:
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in the recipes, so you won't get accidentally updated to the next major version.

## ISO

If build on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
# For pureuda-os
cosign verify --key cosign.pub ghcr.io/pandabrain/pureuda-os

# For pureuda-os-gaming
cosign verify --key cosign.pub ghcr.io/pandabrain/pureuda-os-gaming
```
