{
  flake.nixosModules.fish = {
    programs.fish.enable = true;

    home-manager.users.braam.programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
      '';

      shellAliases = {
        ll = "ls -l";
        edit = "sudo -e";
        snr-switch = "sudo nixos-rebuild switch --flake ~/dotfiles --impure";
        snr-update = "sudo nixos-rebuild switch --flake ~/dotfiles --impure --update";
      };
    };
  };
}
