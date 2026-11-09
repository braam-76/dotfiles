{
  flake.nixosModules.alacritty = {
    home-manager.users.braam = {
      # Stylix supplies colors and the shared dotfiles.font settings.
      programs.alacritty.enable = true;
      stylix.targets.alacritty.enable = true;
    };
  };
}
