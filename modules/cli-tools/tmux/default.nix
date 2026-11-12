{
  flake.nixosModules.tmux = {
    home-manager.users.braam = {
      programs.tmux = {
        enable = true;
        extraConfig = builtins.readFile ./tmux.conf;
      };
      stylix.targets.tmux.enable = true;
    };
  };
}
