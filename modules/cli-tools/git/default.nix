{
  flake.nixosModules.git = { ... }: {
    programs.git = {
      enable = true;
      config.user = {
        name  = "Ilgar Gamidov";
        email = "braam76.gamidov@yandex.com";
      };
    };
  };
}
