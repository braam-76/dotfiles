{ inputs, ... }: {
  flake.nixosModules.happ = { ... }: {
    imports = [ inputs.happ.nixosModules.default ];
    services.happ = {
      enable = true;
      forceXwayland = true;
    };
  };
}