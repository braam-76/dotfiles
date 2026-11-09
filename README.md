# Dotfiles

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
    │   ├── alacritty/default.nix     # Terminal emulator and Stylix integration
    │   ├── firefox/default.nix       # Firefox
    │   ├── flatpak/default.nix       # Flatpak
    │   ├── plasma/default.nix        # Plasma and SDDM; default login session
    │   ├── mango/
    │   │   ├── default.nix           # MangoWM and supporting packages
    │   │   └── config.conf           # Window manager settings and keybindings
    │   └── waybar/
    │       ├── default.nix           # Waybar and config links
    │       ├── config.jsonc          # Bar modules and layout
    │       └── style.css             # Bar styling
    ├── cli-tools/
    │   ├── default.nix               # CLI module imports, wget and curl
    │   ├── git/default.nix           # Git and user identity
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
            ├── default.nix           # Pi package and Home Manager config links
            └── config/
                ├── .gitignore        # Excludes private and runtime data
                └── agent/
                    ├── settings.json
                    ├── CLAUDE-HERDR-SETUP.md
                    ├── extensions/
                    │   ├── claude-style.ts
                    │   ├── herdr-agent-state.ts
                    │   └── herdr-subagents.ts
                    ├── npm/.gitignore
                    └── tests/claude-herdr.test.mjs
```

Hardware configuration: `/etc/nixos/hardware-configuration.nix` (outside this repository).
Ignored Pi credentials, caches and sessions are omitted from the map.

## Shared colorscheme (Stylix)

Edit **`modules/desktop/theme.nix`** to change the desktop palette:

```nix
base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
polarity = "dark";
```

For example, use `catppuccin-mocha.yaml`, `nord.yaml`, or `gruvbox-dark-medium.yaml`.
When choosing a light scheme, also change `polarity` to `"light"`.
The available YAML files are in the `pkgs.base16-schemes` package.

Stylix themes Alacritty, Fuzzel, Mako, Neovim, GTK, and KDE/Plasma. Qt apps
keep the native KDE platform integration and use the KDE palette. Bootloader,
login screen, console, and wallpaper are intentionally left alone. App targets
are enabled explicitly in `theme.nix`; add targets there when adding new apps.
Some applications and Flatpaks may ignore system themes or need extra permissions.

Two small adapters use the same Stylix palette without replacing your live configs:

- **Mango:** Home Manager generates `~/.config/mango/colors.conf` from
  `config.lib.stylix.colors`. The live-linked `mango/config.conf` imports it with
  `source=~/.config/mango/colors.conf`. All compositor color settings are in the
  generated file; edit their palette mappings in `modules/desktop/mango/default.nix`.
- **Waybar:** Home Manager generates `~/.config/waybar/colors.css`, imported by
  the live-linked `style.css`. Layout and styling remain editable as before.

Neovim's repository `init.lua` remains live-linked at `~/.config/nvim/dotfiles.lua`.
Home Manager generates the entry-point `~/.config/nvim/init.lua`, loads Stylix's
theme plugin, then runs that live file. Don't add a separate `colorscheme` command
to the repository `init.lua` unless you want to override the shared theme.

To apply (make sure any new Nix modules are tracked by Git first):

```sh
git add modules/desktop/theme.nix
sudo nixos-rebuild switch --flake .#nixos
```

Then reload Mango with **Super+Shift+R** and restart Neovim, Waybar and other
running apps, or log out and back in. Mako reloads its generated config during
Home Manager activation. Palette changes require a rebuild; ordinary Mango
keybinding and Waybar stylesheet edits still use the existing live links.

## Wallpapers (Mango)

`awww` is installed by `modules/desktop/mango/default.nix`, and Mango starts
`awww-daemon` once per session through `modules/desktop/mango/config.conf`.
Plasma continues to manage its own wallpaper.

After rebuilding, log out and back into Mango, then choose a wallpaper:

```sh
awww img ~/Pictures/wallpaper.jpg
```

The daemon caches and restores the last wallpaper on subsequent starts.
To use it immediately in an existing Mango session, run `awww-daemon &` once
before `awww img`. Wallpaper selection is independent of the Stylix palette.

## Shared font

Edit the defaults in `modules/system/fonts.nix` to change the font everywhere:

- `dotfiles.font.name`: font family (currently `JetBrainsMono Nerd Font`).
- `dotfiles.font.package`: package providing that family (currently `pkgs.nerd-fonts.jetbrains-mono`).
- `dotfiles.font.size`: default size in points (currently `10`).

Change both the name and package when switching families, then rebuild NixOS.
Alacritty, Waybar, Fuzzel, Mako, GTK and KDE/Qt use these settings. Fontconfig
also uses the family for generic serif, sans-serif and monospace requests.
Emoji and icon fonts remain available as fallbacks. Applications with their own
explicit font preferences may still override these defaults.

Waybar's `style.css` remains live-linked; it imports a generated `font.css`.
Font changes require a rebuild and restarting applications (or logging out/in).
Terminal applications such as Neovim and terminal Emacs inherit Alacritty's font.

Future NixOS app modules can read `config.dotfiles.font`; Home Manager modules
can read `osConfig.dotfiles.font`. For example, a graphical Emacs module could
set its default face with:

```nix
home-manager.users.braam = { osConfig, ... }: let
  font = osConfig.dotfiles.font;
in {
  programs.emacs.extraConfig = ''
    (set-face-attribute 'default nil
      :family ${builtins.toJSON font.name}
      :height ${toString (font.size * 10)})
  '';
};
```
