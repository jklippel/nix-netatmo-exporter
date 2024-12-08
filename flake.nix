{
  description = "Netatmo Exporter";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux"; };
      stdenv.mkDerivation{
        name = "netatmo-exporter";
        src = fetchFromGitHub {
          owner = "jklippel";
          repo = "netatmo-exporter";
          rev = "nixify";
          hash = "sha256-wP8/xSSxbPGTGh9iq0jU4lEi/LYSioW49Y0/qmUArLs=";
        };
        buildInputs = [ gnumake go git ];
        buildPhase = "export HOME=$(mktemp -d);make";
        installPhase = "mkdir -p $out/bin; install -t $out/bin netatmo-exporter";
      };

  };
}
