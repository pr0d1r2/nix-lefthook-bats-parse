{
  self,
  nixpkgs,
  set-and-setting,
  ...
}:
{
  packages = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ] (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in {
      default = pkgs.writeShellApplication {
        name = "lefthook-bats-parse";
        runtimeInputs = [ pkgs.bats ];
        text = builtins.readFile ./lefthook-bats-parse.sh;
      };
      setting = (set-and-setting.lib.mkSetting { inherit pkgs; }).materialized;
    });

  devShells = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ] (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    set-and-setting.lib.mkDevShells {
      inherit pkgs;
      basePackages = (set-and-setting.lib.materializationFor { inherit pkgs; fragments = [ "base" "nix" "shell" "ascii" "markdown" "yaml" ]; }).packages ++ [ self.packages.${system}.default ];
    });

  checks = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ] (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    set-and-setting.lib.checksFor { inherit pkgs; fragments = [ "base" "nix" "shell" "ascii" "markdown" "yaml" ]; src = ./.; });

  apps = { };
}
