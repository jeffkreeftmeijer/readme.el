{
  inputs = {
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};

        readme-el = pkgs.stdenv.mkDerivation {
          name = "readme.el";
          src = ./.;
          installPhase = ''
            mkdir -p $out/bin
            cp readme.el $out
          '';
        };

        emacs = ((pkgs.emacsPackagesFor pkgs.emacs-nox).emacsWithPackages (epkgs: [
          epkgs.ox-gfm
          (epkgs.trivialBuild {
            pname = "ox-md-title";
            version = "0.3.0";
            src = pkgs.fetchFromGitHub {
              owner = "jeffkreeftmeijer";
              repo = "ox-md-title.el";
              rev = "53ddb4c8001ba081eb994c2d9444b5ef860c7e9d";
              sha256="sha256-kKMaPEw2w52qwyXX4id+PLDxxE0XPq84vr70iKoHUcY=";
            };
          })
        ]));

      in {
        packages.default = pkgs.writeShellApplication {
          name = "readme";
          text = ''
            ${emacs}/bin/emacs --no-site-file --batch "$1" --load ${readme-el}/readme.el --eval "(readme/to-markdown \"$2\")"
          '';
        };
      }
    );
}
