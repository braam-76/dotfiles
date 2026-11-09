{
  flake.nixosModules.pi-code = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.pi-coding-agent ];

    home-manager.users.braam = { config, ... }:
      let
        piConfig = "modules/ai/pi-code/config/agent";
      in
      {
        home.file = {
          ".pi/agent/settings.json".source =
            config.lib.dotfiles.link "${piConfig}/settings.json";
        };
      };
  };
}
