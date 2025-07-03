{
  description = "Patch Habitica APK to replace habitica.com";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            openjdk
            apktool
            apksigner
            coreutils
            bash
          ];
        };
        packages.default = pkgs.stdenv.mkDerivation {
          name = "patch-habitica";
          src = ./.;
          buildInputs = [ pkgs.makeWrapper ];
          installPhase = ''
            mkdir -p $out/bin
            cp $src/patch-habitica.sh $out/bin/patch-habitica
            chmod +x $out/bin/patch-habitica
            wrapProgram $out/bin/patch-habitica \
              --prefix PATH : ${pkgs.lib.makeBinPath [
                pkgs.openjdk
                pkgs.apktool
                pkgs.apksigner
                pkgs.coreutils
                pkgs.bash
              ]}
          '';
        };
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/patch-habitica";
        };
      });
}
