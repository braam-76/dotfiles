{
  flake.nixosModules.vscode = { pkgs, ... }: {
    home-manager.users.braam.programs.vscode = {
      enable = true;
      profiles.default = {
        extensions = [ pkgs.vscode-extensions.mkhl.direnv ];
        mutableUserSettings = true;
        userSettings = builtins.fromJSON (builtins.readFile ./settings.json);
      };
    };
  };
}
