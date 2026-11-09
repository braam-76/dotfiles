{
  flake.nixosModules.mango = { pkgs, ... }: {
    programs.mango.enable = true;
 
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

      # The daemon is started by Mango, not by Plasma's graphical session.
      home.packages = [ pkgs.awww ];

      # Stylix supplies colors and the shared dotfiles.font settings.
      programs.fuzzel.enable = true;

      # Home Manager preserves Mako's D-Bus activation and lets Stylix
      # generate the notification colors and shared font.
      services.mako.enable = true;
    };

    environment.systemPackages = with pkgs; [
      waybar
      mako
      xwayland-satellite

      wl-clipboard
    ];
  };
}

