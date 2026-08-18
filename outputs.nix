{
  self,
  nixpkgs,
  set-and-setting,
  ...
}:
{
  packages =
    nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ]
      (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.writeShellApplication {
            name = "lefthook-bats-parse";
            runtimeInputs = [ pkgs.bats ];
            text = builtins.readFile ./lefthook-bats-parse.sh;
          };
          actionlint = pkgs.writeShellApplication {
            name = "lefthook-actionlint";
            runtimeInputs = [ pkgs.actionlint ];
            text = builtins.readFile ./lefthook-actionlint.sh;
          };
          setting = (set-and-setting.lib.mkSetting { inherit pkgs; }).materialized;
        }
      );

  devShells =
    nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ]
      (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        set-and-setting.lib.mkDevShells {
          inherit pkgs;
          basePackages =
            (set-and-setting.lib.materializationFor {
              inherit pkgs;
              fragments = [
                "base"
                "actions"
                "nix"
                "shell"
                "ascii"
                "markdown"
                "yaml"
              ];
            }).packages
            ++ [ self.packages.${system}.default self.packages.${system}.actionlint ];
        }
      );

  checks = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ] (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    set-and-setting.lib.checksFor {
      inherit pkgs;
      fragments = [
        "base"
        "nix"
        "shell"
        "ascii"
        "markdown"
        "yaml"
      ];
      src = ./.;
    }
  );

  apps = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ] (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (self.packages.${system}) setting;
      materialization = set-and-setting.lib.materializationFor {
        inherit pkgs;
        fragments = [
          "base"
          "actions"
          "nix"
          "shell"
          "ascii"
          "markdown"
          "yaml"
        ];
      };
    in
    {
      confirm = {
        type = "app";
        program = "${
          pkgs.writeShellApplication {
            name = "confirm";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.diffutils
              pkgs.findutils
              pkgs.gawk
              pkgs.git
              pkgs.gnugrep
            ]
            ++ materialization.packages
            ++ [ self.packages.${system}.actionlint ];
            text =
              builtins.replaceStrings
                [
                  "@FRAGMENTS_DIR@"
                  "@ASSEMBLE_SCRIPT@"
                  "@DETECT_SCRIPT@"
                  "@SETTING_SRC@"
                  "@CONFIRM_SCRIPT@"
                  "@CONFIRM_REV@"
                ]
                [
                  "${set-and-setting}/setting/integrations/lefthook"
                  "${set-and-setting}/setting/lib/assemble-lefthook.sh"
                  "${set-and-setting}/setting/lib/detect-fragments.sh"
                  "${setting}"
                  "${set-and-setting}/lib/confirm.sh"
                  (set-and-setting.rev or "unknown")
                ]
                (builtins.readFile ./nix/confirm.sh);
          }
        }/bin/confirm";
      };
    }
  );
}
