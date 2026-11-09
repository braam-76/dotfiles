{
  flake.nixosModules.keyboard = {
    services.xserver.xkb = {
        layout = "us,ru";
        options = "grp:win_space_toggle";
    };
  };
}
