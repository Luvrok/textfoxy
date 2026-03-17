{
  description = "firefox theme for the tui enthusiast (with librewolf support)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      pkgsForEach = nixpkgs.legacyPackages;
    in
    {
      packages = forAllSystems (system: {
        default = pkgsForEach.${system}.callPackage ./nix/pkgs/default.nix { };
      });

      lib = forAllSystems (system: {
        wrapTextfoxy = pkgsForEach.${system}.callPackage ./nix/pkgs/wrapTextfoxy.nix { };
      });

      nixosModules.default = self.nixosModules.textfoxy; # convention
      nixosModules.textfoxy = import ./nix/modules/nixos.nix inputs;

      homeManagerModules.default = self.homeManagerModules.textfoxy;
      homeManagerModules.textfoxy = import ./nix/modules/home-manager.nix inputs;
    };
}
