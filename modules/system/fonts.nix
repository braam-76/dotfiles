{
  flake.nixosModules.fonts = { config, lib, pkgs, ... }: let
    font = config.dotfiles.font;
  in {
    options.dotfiles.font = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "JetBrainsMono Nerd Font";
        description = "Shared font family for desktop applications and editors.";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.nerd-fonts.jetbrains-mono;
        description = "Package providing the shared font family.";
      };
      size = lib.mkOption {
        type = lib.types.ints.positive;
        default = 10;
        description = "Default application font size in points.";
      };
    };

    config.fonts = {
      packages = [
        font.package
        pkgs.noto-fonts
        pkgs.noto-fonts-color-emoji
        pkgs.font-awesome
      ];
      fontconfig.defaultFonts = {
        serif = [ font.name ];
        sansSerif = [ font.name ];
        monospace = [ font.name ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
