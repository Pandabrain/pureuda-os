![Pureuda OS Watermark](pureuda-os-watermark.png)

# 푸르다 OS

푸르다 OS (Pureuda OS) is my personal custom Linux image, built with [BlueBuild](https://blue-build.org) using Fedora Atomic Cosmic as a base.

> [!IMPORTANT]
> This is my personal image and is primarily intended for my own use. It contains a large amount of pre-installed software and configurations that may not be suitable for everyone and are subject to change at any time without notice.

## 🍴 Credits & Fork Information

This project is a fork of **[Origami Linux](https://origami.wf)**. I would like to thank the Origami Linux team for their groundwork.

If you are looking for a properly maintained and built Linux distribution for general use, I highly recommend visiting the **[Origami Linux website](https://origami.wf)** and giving their OS a try!

## 🚀 How to Use

Currently, only a rebase from an existing Fedora Atomic (COSMIC) installation is supported.

### Via bootc (Recommended)

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

## 🛠️ Changes & Features

Compared to the original Fedora COSMIC Atomic image, Pureuda OS includes the following changes:

- **Custom Kernel**: Powered by `cachyos-lto` for improved performance and responsiveness.
- **Performance Tweaks**: Includes `cachyos-settings`, `scx-scheds`, and `scx-tools`.
- **Pre-installed Software**:
  - **Development**: JetBrains Toolbox, Flutter dependencies (clang, cmake, ninja-build, etc.), LazyGit, Zellij.
    - **Note:** Flutter can be installed and updated via a `blujust` script.
  - **Browsing**: Vivaldi is pre-installed as the default browser. Google Chrome and Firefox are also available although intended primarily for development purposes.
  - **Privacy & Productivity**: Proton VPN, Proton Pass, Proton Mail, Joplin.
  - **Gaming**: Steam, MangoHud, Gamescope.
    > [!NOTE]
    > A full Gamescope session can be started directly from the login screen, giving you the full SteamOS experience without sacrificing desktop usability, thanks to the helper scripts from [steam-using-gamescope-guide](https://github.com/shahnawazshahin/steam-using-gamescope-guide). Steam is also installed natively, providing better hardware access and more performance.
  - **Utilities**: Starship, Fastfetch, Topgrade, Tealdeer, Btop, Yazi, Eza, Zoxide, Bat, Ripgrep.
  - **System Tools**: Mission Center, GearLever, Warehouse, Bazaar, DistroShelf.
- **Input Methods & Languages**:
  - **Fcitx5**: Pre-installed and configured with Japanese (`fcitx5-mozc`) and Hangul (`fcitx5-hangul`) plugins, ready to use via the `fcitx5-configtool`.
- **Enhanced Fonts & Theming**:
  - Nerd Fonts (JetBrains Mono), Maple Mono NF.
  - Noto Sans/Serif for Korean and Japanese support.
  - Bibata cursor theme.
- **LUKS Automation**: Includes a **blujust** script (part of the base image) to easily setup automatic LUKS unlocking via **TPM2**.
- **Container Support**: Podman Compose and Podman Desktop included.
- **Flatpak Integration**: Pre-configured Flathub and COSMIC flatpak repositories with a selection of essential apps.

## 🛠️ GitLab CI Enable Switch

To enable the GitLab CI pipeline, set the project CI/CD variable `GITLAB_CI_ENABLED` to `true`. If the variable is missing or set to any other value, the pipeline will not run.
