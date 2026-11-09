{
  flake.nixosModules.waybar = { config, pkgs, ... }: let
    font = config.dotfiles.font;
  in {
    programs.waybar.enable = true;

    # The systemd user service does not inherit the interactive shell PATH.
    # Include every external command used by config.jsonc and mango.py.
    systemd.user.services.waybar.path = [
      pkgs.python3
      pkgs.fuzzel
      pkgs.alacritty
      pkgs.btop
      pkgs.pavucontrol
      pkgs.networkmanagerapplet
      pkgs.wireplumber
      pkgs.brightnessctl
      pkgs.systemd
      config.programs.mango.package
    ];

    home-manager.users.braam = { config, ... }: {
      home.packages = [
        pkgs.python3
        pkgs.brightnessctl
        pkgs.pavucontrol
        pkgs.networkmanagerapplet
      ];

      xdg.configFile."waybar/mango.py".source =
        config.lib.dotfiles.link "modules/desktop/waybar/mango.py";

      xdg.configFile."waybar/config.jsonc".source = 
        config.lib.dotfiles.link "modules/desktop/waybar/config.jsonc";

      # Keep the upstream floating layout integrated with the shared palette.
      xdg.configFile."waybar/colors.css".text = let
        c = config.lib.stylix.colors.withHashtag;
      in ''
        @define-color foreground ${c.base05};
        @define-color foreground-inactive ${c.base04};
        @define-color background ${c.base00};
        @define-color surface ${c.base02};
        @define-color accent ${c.base0D};
        @define-color urgent ${c.base08};
      '';

      xdg.configFile."waybar/font.css".text = ''
        * {
          font-family: ${builtins.toJSON font.name}, "Font Awesome 7 Free", "Font Awesome 7 Brands", monospace;
          font-size: ${toString font.size}pt;
        }
      '';

      xdg.configFile."waybar/style.css".source =
        config.lib.dotfiles.link "modules/desktop/waybar/style.css";

      xdg.configFile."waybar/platform_profile.sh".source =
        config.lib.dotfiles.link "modules/desktop/waybar/platform_profile.sh";
    };


  };
}
