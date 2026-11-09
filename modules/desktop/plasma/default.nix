{
  flake.nixosModules.plasma = { lib, ... }: {
    services = {
      xserver.enable = true;
      desktopManager.plasma6.enable = true;
      displayManager.sddm.enable = true;
      displayManager.defaultSession = lib.mkForce "plasma";
    };
  };
}
