{ self, ... }: {
  flake.nixosModules.cli-tools = { pkgs, ... }: {
    imports = with self.nixosModules; [
      zsh
      git
      yazi
    ];

    environment.systemPackages = with pkgs; [ wget curl btop ];
  };
}
