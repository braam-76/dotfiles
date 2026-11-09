{ self, ... }: {
  flake.nixosModules.development = {
    imports = with self.nixosModules; [
      neovim
      vscode
      languages
    ];
  };
}
