{
  flake.nixosModules.languages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Go
      go
      gopls

      # Nix
      nil
      nixfmt

      # Lua
      lua
      lua-language-server
      stylua

      # Python
      python3
      basedpyright
      isort
      black

      # Rust
      rustc
      cargo
      rust-analyzer
      rustfmt
      clippy

      # C/C++ and CMake
      clang
      clang-tools # clangd
      cmake
      cmake-language-server
      gnumake
      pkg-config

      # JavaScript and formatting
      nodejs
      prettierd
      prettier
      bun

      # Neovim live grep and Wayland clipboard
      ripgrep
      wl-clipboard
    ];
  };
}
