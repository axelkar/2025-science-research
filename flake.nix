{
  description = "2025 science research project - measurement tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) python3 lib;
      godirect = python3.pkgs.buildPythonPackage rec {
        pname = "godirect";
        version = "1.1.4";
        pyproject = true;

        # https://github.com/VernierST/godirect-py/issues/34
        src = pkgs.fetchgit {
          url = "https://github.com/VernierST/godirect-py.git";
          rev = "e1ce7c512974587840d9081c5ee03dcd246fd2b3";
          hash = "sha256-YIi3U/txlocBTSfxQpvkN1BIc+bLPWoH1FRe85EEMuU=";
        };

        build-system = with python3.pkgs; [
          setuptools
        ];

        dependencies = with python3.pkgs; [
          hidapi
          bleak
        ];

        # has no tests
        doCheck = false;

        meta = {
          description = "Library to interface with GoDirect devices via USB and BLE";
          homepage = "https://github.com/vernierst/godirect-py";
          license = [ lib.licenses.gpl3Only ];
          maintainers = [ lib.maintainers.axka ];
        };
      };
    in
    {
      devShells.default = pkgs.mkShellNoCC {
        buildInputs = [
          (pkgs.python3.withPackages (ps: with ps; [
            godirect
          ]))
        ];
      };
    });
}

