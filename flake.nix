{
  description = "Netatmo Exporter";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      cfg = self.config.services.netatmoexporter;
      inherit(nixpkgs.lib)
        types
        mkEnableOption
        mkOption
        mkIf
        ;
    in
    {

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

      options = {
        services.netatmoexporter = {
          enable = mkEnableOption ''
            Netatmo Exporter for Prometheus.
          '';

          dataDir = mkOption {
            type = types.str;
            default = "/var/lib/netatmoexporter";
            description = nixpkgs.lib.mdDoc ''
              The path where the netatmo export keeps its config.
             '';
          };

          clientId = mkOption {
            type = types.str;
            default = null;
            description = nixpkgs.lib.mdDocs ''
              The clientId of the netatmo app associated with your setup.
              '';
          };

          secret = mkOption {
            type = types.str;
            default = null;
            description = nixpkgs.lib.mdDocs ''
              The secret of the netatmo app associated with your setup.
              '';
          };

          tokenFile = mkOption {
            type = types.str;
            default = "token.json";
            description = nixpkgs.lib.mdDocs ''
              The name to the token file to use.
              '';
          };

          logLevel = mkOption {
            type = types.str;
            default = "info";
            description = nixpkgs.lib.mdDocs ''
              The log level to use with netatmo exporter.
            '';
          };

        };
      };

      config = mkIf cfg.enable {

        users.user.netatmoxport = {
          description = "Netatmo Exporter daemon user";
          isSystemUser = true;
          group = "netatmoxport";
        };

        users.groups.netatmoxport = { };

        systemd.services.netatmoexporter = {
          description = "Netatmo Exporter for Prometheus";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];

          serviceConfig = {
            User = "netatmoxport";
            Group = "netatmoxport";
            Restart = "always";
            ExecStart = "${nixpkgs.lib.getBin cfg.package}/bin/netatmo-exporter";
            StateDirectory = "netatmoxport";
            StateDirectoryMode = "0750";
          };

          environment = {
            NETATMO_CLIENT_ID="${cfg.services.netatmoexporter.clientId}";
            NETATMO_CLIENT_SECRET="${cfg.services.netatmoexporter.secret}";
            NETATMO_EXPORTER_TOKEN_FILE= "${cfg.services.netatmoexporter.dataDir}/${cfg.services.netatmoexporter.tokenFile}";
            NETATMO_LOG_LEVEL= "${cfg.services.netatmoexporter.logLevel}";
          };

        };
      };

  };
}
