{
  flake.nixosModules.vscode = { ... }: {
    home-manager.users.braam.programs.vscode.enable = true;
  };
}
