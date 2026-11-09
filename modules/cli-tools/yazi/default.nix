{
  flake.nixosModules.yazi = { pkgs, ... }: {
    home-manager.users.braam = {
      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        shellWrapperName = "y";

        # nixpkgs' wrapped Yazi already supplies ffmpeg-headless, _7zz
        # (full 7zz, not 7zr), jq, poppler-utils, fd, ripgrep, fzf,
        # zoxide, resvg, ImageMagick 7 and chafa. Reuse that suite instead
        # of installing a second copy/list of the preview dependencies.
        # wl-clipboard is already used by Mango; expose it in Yazi's PATH too.
        extraPackages = [ pkgs.wl-clipboard ];
      };

      # Populate directory history from Zsh for Yazi's zoxide navigation.
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };

      # Yazi inherits its font from the terminal. Alacritty already uses
      # dotfiles.font (JetBrainsMono Nerd Font) through Stylix.
      stylix.targets.yazi.enable = true;
    };
  };
}
