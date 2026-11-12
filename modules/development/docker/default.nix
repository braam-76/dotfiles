{
  flake.nixosModules.docker = {
    virtualisation.docker.enable = true;
    users.users.braam.extraGroups = [ "docker" ];
  };
}
