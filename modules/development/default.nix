{ self, ... }: {
  flake.nixosModules.development = { pkgs, ... }: {
    imports = with self.nixosModules; [
      neovim
      vscode
      languages
      docker
      qemu
    ];

    home-manager.users.braam = {
      home.packages = [ pkgs.devenv ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
      };
    };
  };
}
