{
  flake.nixosModules.helium = { pkgs, ... }: let
    # Helium is not yet packaged in the pinned Nixpkgs.
    pname = "helium";
    version = "0.21.1.1";
    src = pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
      sha256 = "a62bc4081b99709b3117165cf7abe7111d3b544671ab17232f429b9b0544b3fa";
    };
    appimageContents = pkgs.appimageTools.extract {
      inherit pname version src;
    };
    helium = pkgs.appimageTools.wrapType2 {
      inherit pname version src;
      extraInstallCommands = ''
        install -Dm444 ${appimageContents}/helium.desktop $out/share/applications/helium.desktop
        substituteInPlace $out/share/applications/helium.desktop \
          --replace-fail 'Exec=helium' "Exec=$out/bin/helium"
        install -Dm444 ${appimageContents}/helium.png $out/share/icons/hicolor/256x256/apps/helium.png
      '';
      meta = {
        description = "Private, fast, and honest web browser";
        homepage = "https://helium.computer/";
        license = pkgs.lib.licenses.gpl3;
        platforms = [ "x86_64-linux" ];
        mainProgram = "helium";
      };
    };
  in {
    environment.systemPackages = [ helium ];
  };
}
