# Dotfiles

```sh
snr-switch  # sudo nixos-rebuild switch --flake ~/dotfiles --impure
snr-update  # sudo nixos-rebuild switch --flake ~/dotfiles --impure --update
```

## Screen lock (Mango)

Run `snr-switch`, then log out and back into Mango to start the idle watcher.

- `Super+L`: lock immediately (`Super+Shift+L` switches layouts).
- Terminal: `hyprlock --grace 0` or `loginctl lock-session`.
- Automatically locks after 10 minutes idle and before suspend.

Hyprlock uses your account password in a rectangular input field, with Stylix
colors and a blurred `~/Pictures/wallpaper-nixos-big.png` background. Change the
wallpaper path in `modules/desktop/mango/default.nix` if needed.
The idle watcher starts only in Mango; Plasma keeps its own screen locker.

To start (or replace) the idle watcher without logging out after `snr-switch`:

```sh
pkill -x swayidle
swayidle -w timeout 600 'hyprlock --grace 0' \
  before-sleep 'hyprlock --grace 0' lock 'hyprlock --grace 0' &
disown
```

## Screenshots (Mango)

After running `snr-switch`, reload Mango with `Super+Shift+R`.

- `Print` or `Super+Shift+S`: select an area (`Escape` cancels).
- `Shift+Print`: capture the full screen (all monitors).
- Terminal: `screenshot region` or `screenshot full`.

Screenshots are copied to the clipboard as PNG images and added to clipboard
history first. Click the notification (within 15 seconds) to open a Save dialog
and choose the folder and filename. Dismissing the notification or cancelling the
dialog does not save a permanent file. The temporary capture lives only in your
user runtime directory and is removed when the notification/dialog closes.

## Clipboard history (Mango)

`Super+V` opens Walker's clipboard picker backed by Elephant—the same stack
used by Omarchy. It has image previews, searchable text history, and action
hints, with a rounded panel colored by your Stylix theme. Select an entry to copy
it back to the clipboard, then paste normally. `Escape` closes the picker;
`Alt+J` shows available actions (including removing entries). Fuzzel remains the
application launcher on `Super+D`.

Run `snr-switch`, then log out and back into Mango to replace the old clipboard
watchers with Elephant. The database and image previews stay under
`$XDG_RUNTIME_DIR/clipboard-cache` and temporary images under
`$XDG_RUNTIME_DIR/clipboard-tmp`. History (including pinned entries) clears on
shutdown/reboot and may clear after your last logout.

Old cliphist history is not imported. If upgrading from the original persistent
setup, remove its old database with `rm -f ~/.cache/cliphist/db`.

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
    │   │   ├── config.conf           # Window manager settings and keybindings
    │   │   └── clipboard.css         # Walker clipboard picker styling
    │   └── waybar/
    │       ├── default.nix           # Waybar and config links
    │       ├── config.jsonc          # Bar modules and layout
    │       ├── mango.py              # Mango window title and power menu
    │       ├── platform_profile.sh   # ACPI platform profile status
    │       └── style.css             # Bar styling
    ├── cli-tools/
    │   ├── default.nix               # CLI module imports, wget, curl and btop
    │   ├── fish/default.nix          # Default shell and aliases
    │   ├── git/default.nix           # Git and user identity
    │   ├── yazi/default.nix          # Yazi file manager and Zoxide integration
    │   └── zsh/default.nix           # Optional shell, aliases and history
    ├── development/
    │   ├── default.nix               # Development module imports
    │   ├── docker/default.nix        # Docker daemon and user access
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
