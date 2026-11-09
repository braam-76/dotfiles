{ inputs, ... }: {
  flake.nixosModules.braam = { pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";

      sharedModules = [
        ({ config, lib, ... }: {
          options.dotfiles.root = lib.mkOption {
            type = lib.types.str;
            default = "${config.home.homeDirectory}/dotfiles";
            description = "Absolute path to the editable dotfiles checkout.";
          };

          config.lib.dotfiles.link = relativePath:
            config.lib.file.mkOutOfStoreSymlink
              "${config.dotfiles.root}/${relativePath}";
        })
      ];

      users.braam = {
        home.username = "braam";
        home.homeDirectory = "/home/braam";
        home.stateVersion = "26.05";
      };
    };

    users.users."braam" = {
      isNormalUser = true;
      description = "Ilgar Gamidov";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.zsh;
      packages = with pkgs; [
        codex
      ];
    };
  };
}
