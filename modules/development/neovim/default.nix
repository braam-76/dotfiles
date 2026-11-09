{
  flake.nixosModules.neovim = {
    home-manager.users.braam = { config, lib, ... }: {
      programs.neovim = {
        enable = true;
        # Run the live config after Home Manager's plugin/runtime setup and
        # Stylix's colorscheme. The generated init.lua owns that ordering.
        initLua = lib.mkAfter ''
          dofile(vim.fn.stdpath("config") .. "/dotfiles.lua")
        '';
      };

      xdg.configFile."nvim/dotfiles.lua".source =
        config.lib.dotfiles.link "modules/development/neovim/init.lua";
    };
  };
}
