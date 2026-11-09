{
  flake.nixosModules.zsh = {
    programs.zsh.enable = true;

    home-manager.users.braam.programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    
      shellAliases = {
        ll = "ls -l";
        edit = "sudo -e";
	snr-switch = "sudo nixos-rebuild switch --flake ~/dotfiles --impure";
	snr-update = "sudo nixos-rebuild switch --flake ~/dotfiles --impure --update";
      };
    
      history = {
        size = 10000;
        save = 10000;
        path = "$HOME/.zsh_history";
        ignoreAllDups = true;
      };
    };
  };
}
