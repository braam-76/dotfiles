{ inputs, ... }: {
  flake.nixosModules.theme = { config, pkgs, ... }: let
    font = config.dotfiles.font;
  in {
    imports = [ inputs.stylix.nixosModules.stylix ];

    stylix = {
      enable = true;
      # One place to change the palette for all themed applications.
      # equilibrium-gray-dark.yaml
      # mountain.yaml
      base16Scheme = "${pkgs.base16-schemes}/share/themes/mountain.yaml";
      polarity = "dark";

      # Theme desktop apps, not the bootloader, login screen or console.
      # Home Manager inherits the palette and fonts automatically.
      autoEnable = false;
      fonts = {
        serif = { inherit (font) name package; };
        sansSerif = { inherit (font) name package; };
        monospace = { inherit (font) name package; };
        sizes = {
          applications = font.size;
          desktop = font.size;
          popups = font.size;
          terminal = font.size;
        };
      };
    };

    home-manager.users.braam.stylix.targets = {
      fuzzel.enable = true;
      gtk.enable = true;
      kde.enable = true;
      mako.enable = true;
      neovim.enable = true;
      vscode.enable = true;
      # Mango and Waybar use small adapters in their own modules, keeping
      # the main config.conf and style.css editable through live links.
      # Qt keeps the native KDE platform theme and uses Stylix's KDE palette.
    };
  };
}
