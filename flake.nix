{
  description = "My personal website";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          website = pkgs.stdenv.mkDerivation {
            name = "blog";
            src = self;
            buildInputs = with pkgs; [
              git
              go
            ];
            buildPhase = ''
              ${pkgs.hugo}/bin/hugo mod get -u
              ${pkgs.hugo}/bin/hugo
            '';
            installPhase = "cp -r public $out";
          };

          default = website;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            hugo
            go
          ];
        };
      }
    );
}
