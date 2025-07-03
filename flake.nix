{
  description = "Patch Habitica APK to replace habitica.com";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        openjdk
        apktool
        apksigner
        coreutils
        bash
      ];
    };

    packages.${system}.default = pkgs.stdenv.mkDerivation {
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

    apps.${system}.default = {
      type = "app";
      program = "${self.packages.${system}.default}/bin/patch-habitica";
    };
  };
}
