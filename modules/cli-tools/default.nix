{ self, ... }: {
  flake.nixosModules.cli-tools = { pkgs, ... }: {
    imports = with self.nixosModules; [
      zsh
      fish
      git
      yazi
      tmux
    ];

    home-manager.users.braam.programs.starship = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    environment.systemPackages = with pkgs; [ wget curl btop ];
  };
}
