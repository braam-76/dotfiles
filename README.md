# Dotfiles

```sh
snr-switch  # sudo nixos-rebuild switch --flake ~/dotfiles --impure
snr-update  # sudo nixos-rebuild switch --flake ~/dotfiles --impure --update
```

## Configuration map

```text
.
├── flake.nix                         # Inputs and automatic module discovery
├── flake.lock                        # Pinned input versions
└── modules/
    ├── parts.nix                     # Supported systems
    ├── hosts/
    │   └── nixos/default.nix          # Host assembly, hardware import and bootloader
    ├── users/
    │   └── braam.nix                 # User account, Home Manager and live config links
    ├── system/
    │   ├── default.nix               # Base system module imports
    │   ├── audio.nix                 # PipeWire and RTKit
    │   ├── fonts.nix                 # Shared font family, package, size and fallbacks
    │   ├── keyboard.nix              # US/Russian keyboard layouts
    │   ├── locale.nix                # Locale and timezone
    │   ├── networking.nix            # NetworkManager
    │   ├── nix-settings.nix          # Unfree packages and Nix features
    │   └── printing.nix              # CUPS
    ├── desktop/
    │   ├── default.nix               # Desktop module imports, audio and printing
    │   ├── theme.nix                 # Shared Stylix colorscheme and app targets
    │   ├── foxglove-dark.yaml        # Additional local Base16 palette (not selected)
    │   ├── alacritty/default.nix     # Terminal emulator and Stylix integration
    │   ├── firefox/default.nix       # Firefox
    │   ├── helium/default.nix        # Helium browser (wrapped AppImage)
    │   ├── libreoffice/default.nix   # LibreOffice
    │   ├── flatpak/default.nix       # Flatpak
    │   ├── plasma/default.nix        # Plasma and SDDM; default login session
    │   ├── mango/
    │   │   ├── default.nix           # MangoWM and supporting packages
    │   │   └── config.conf           # Window manager settings and keybindings
    │   └── waybar/
    │       ├── default.nix           # Waybar and config links
    │       ├── config.jsonc          # Bar modules and layout
    │       ├── mango.py              # Mango window title and power menu
    │       ├── platform_profile.sh   # ACPI platform profile status
    │       └── style.css             # Bar styling
    ├── cli-tools/
    │   ├── default.nix               # CLI module imports, wget, curl and btop
    │   ├── git/default.nix           # Git and user identity
    │   ├── yazi/default.nix          # Yazi file manager and Zoxide integration
    │   └── zsh/default.nix           # Shell, aliases and history
    ├── development/
    │   ├── default.nix               # Development module imports
    │   ├── languages/default.nix     # Languages, LSP servers and formatters
    │   ├── vscode/default.nix        # Visual Studio Code
    │   └── neovim/
    │       ├── default.nix           # Neovim package and config link
    │       └── init.lua              # Options, keybindings and plugins
    ├── vpn/
    │   ├── default.nix               # VPN module imports
    │   ├── happ/default.nix          # Happ
    │   └── throne/default.nix        # Throne and TUN mode
    └── ai/
        ├── default.nix               # AI module imports
        └── pi-code/
            ├── default.nix           # Pi package and live settings link
            └── config/
                ├── .gitignore        # Excludes private and runtime data
                └── agent/
                    └── settings.json
```
