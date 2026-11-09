{ self, ... }: {
  flake.nixosModules.desktop = { config, ... }: let
    font = config.dotfiles.font;
    qtFont = "${font.name},${toString font.size},-1,5,50,0,0,0,0,0";
  in {
    imports = with self.nixosModules; [
      audio
      printing

      theme
      plasma
      mango

      waybar

      alacritty
      firefox
      helium
      libreoffice
      flatpak
    ];

    home-manager.users.braam = {
      gtk = {
        enable = true;
        # Stylix reads the shared dotfiles.font settings.
      };

      qt = {
        enable = true;
        platformTheme.name = "kde";
        kde.settings.kdeglobals = {
          General = {
            font = qtFont;
            fixed = qtFont;
            menuFont = qtFont;
            smallestReadableFont = qtFont;
            toolBarFont = qtFont;
          };
          WM.activeFont = qtFont;
        };
      };
    };
  };
}
