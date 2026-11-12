{
  flake.nixosModules.mango = { pkgs, ... }: let
    elephant = pkgs.elephant.override { enabledProviders = [ "clipboard" ]; };
  in {
    programs.mango.enable = true;
    # Provides PAM authentication for the Wayland lock screen.
    security.pam.services.hyprlock = {};
 
    home-manager.users.braam = { config, ... }: {
      xdg.configFile."mango/config.conf".source =
        config.lib.dotfiles.link "modules/desktop/mango/config.conf";

      # Generated separately so the main Mango config can remain live-linked.
      xdg.configFile."mango/colors.conf".text = let
        c = config.lib.stylix.colors;
      in ''
        # Generated from Stylix; change modules/desktop/theme.nix, not this file.
        root_color=0x${c.base00}ff
        border_color=0x${c.base02}ff
        focus_color=0x${c.base0D}ff
        urgent_color=0x${c.base08}ff
        drop_color=0x${c.base0B}55
        split_color=0x${c.base09}ff
        maximized_screen_color=0x${c.base0B}ff
        scratchpad_color=0x${c.base0C}ff
        global_color=0x${c.base0E}ff
        overlay_color=0x${c.base0C}ff
        shadows_color=0x${c.base00}ff
        dim_focused_color=0x${c.base00}00
        dim_unfocused_color=0x${c.base00}55
      '';

      programs.hyprlock = {
        enable = true;
        settings = {
          general = {
            hide_cursor = true;
            ignore_empty_input = true;
          };
          background = {
            monitor = "";
            path = "${config.home.homeDirectory}/Pictures/wallpaper-nixos-big.png";
            blur_passes = 3;
            blur_size = 8;
            brightness = 0.7;
          };
          input-field = {
            monitor = "";
            size = "320, 56";
            position = "0, -40";
            halign = "center";
            valign = "center";
            rounding = 10;
            outline_thickness = 2;
            dots_center = true;
            fade_on_empty = false;
            placeholder_text = "Password…";
            fail_text = "Incorrect password. Try again.";
          };
        };
      };

      # Background processes are started by Mango, not by Plasma's session.
      home.packages = [
        pkgs.awww
        pkgs.swayidle
        pkgs.walker
        elephant
        (pkgs.writeShellApplication {
          name = "clipboard-daemon";
          runtimeInputs = [ elephant pkgs.coreutils pkgs.wl-clipboard pkgs.imagemagick ];
          text = ''
            # Elephant's database, image previews and temporary copies all stay
            # in volatile storage, including pinned entries.
            export XDG_CACHE_HOME="''${XDG_RUNTIME_DIR:?}/clipboard-cache"
            export TMPDIR="$XDG_RUNTIME_DIR/clipboard-tmp"
            umask 077
            mkdir -p "$XDG_CACHE_HOME/elephant" "$TMPDIR"
            exec elephant
          '';
        })
        (pkgs.writeShellApplication {
          name = "clipboard-history";
          runtimeInputs = [ elephant pkgs.walker ];
          text = ''
            exec walker -m clipboard
          '';
        })
        (pkgs.writeShellApplication {
          name = "screenshot";
          runtimeInputs = with pkgs; [
            coreutils
            grim
            slurp
            wl-clipboard
            xdg-user-dirs
            libnotify
            zenity
          ];
          text = ''
            case "''${1:-region}" in
              region)
                # Escape cancels selection without creating a file.
                geometry=$(slurp) || exit 0
                args=(-g "$geometry")
                ;;
              full) args=() ;;
              *) echo "Usage: screenshot [region|full]" >&2; exit 1 ;;
            esac

            # Temporary capture stays in volatile storage until the notification
            # closes. Keep each capture separate even if the clipboard changes.
            file=$(mktemp --tmpdir="''${XDG_RUNTIME_DIR:?}" screenshot-XXXXXXXX.png)
            trap 'rm -f -- "$file"' EXIT
            grim "''${args[@]}" "$file"
            wl-copy --type image/png < "$file"
            # Elephant watches the clipboard and records the image in history.

            action=$(notify-send --app-name=Screenshot --icon="$file" \
              --wait --expire-time=15000 --action=default="Save…" \
              "Screenshot copied" "Click to choose where to save it.") || exit 0
            [ "$action" = default ] || exit 0

            pictures=$(xdg-user-dir PICTURES)
            destination=$(zenity --file-selection --save --confirm-overwrite \
              --title="Save screenshot" \
              --filename="$pictures/Screenshot-$(date +%Y-%m-%d_%H-%M-%S).png") || exit 0
            [ -n "$destination" ] || exit 0
            cp -- "$file" "$destination"
            notify-send --app-name=Screenshot "Screenshot saved" "$destination"
          '';
        })
      ];

      xdg.configFile."elephant/clipboard.toml".text = ''
        max_items = 200
        ignore_symbols = false
        command = "wl-copy"
      '';

      xdg.configFile."walker/config.toml".text = ''
        theme = "clipboard"
        force_keyboard_focus = true
        selection_wrap = true
        hide_quick_activation = true

        [providers]
        default = ["clipboard"]
        empty = ["clipboard"]
        max_results = 200

        [placeholders.clipboard]
        input = "Search clipboard…"
        list = "Copy something to start your clipboard history"
      '';

      xdg.configFile."walker/themes/clipboard/style.css".text = let
        c = config.lib.stylix.colors;
      in ''
        @define-color base #${c.base00};
        @define-color surface #${c.base01};
        @define-color text #${c.base05};
        @define-color muted #${c.base04};
        @define-color accent #${c.base0D};
        @define-color error #${c.base08};
      '' + builtins.readFile ./clipboard.css;

      # Fuzzel remains the application launcher, not the clipboard picker.
      programs.fuzzel.enable = true;

      # Home Manager preserves Mako's D-Bus activation and lets Stylix
      # generate the notification colors and shared font.
      services.mako = {
        enable = true;
        settings."on-button-left" = "invoke-default-action";
      };
    };

    environment.systemPackages = with pkgs; [
      waybar
      mako
      xwayland-satellite

      wl-clipboard
    ];
  };
}

