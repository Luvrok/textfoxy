inputs:
{ config, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (builtins) baseNameOf;
  cfg = config.textfoxy;
  textfoxyAssets = inputs.self.packages.${system}.default;

  extensionList = lib.optionals cfg.config.tabs.vertical.sidebery.enable [
    inputs.firefox-addons.packages.${system}.sidebery
  ];

  mkProfiles = browserProfiles: lib.mkMerge (map
    (profile: {
      ${profile} = {
        extraConfig = builtins.readFile "${textfoxyAssets}/user.js";
        extensions.packages = extensionList;
        containersForce = true;
        userChrome = lib.mkBefore (builtins.readFile "${textfoxyAssets}/chrome/userChrome.css");
      };
    })
    browserProfiles);

  mkChromeFiles = profileBase: profiles: lib.mkMerge (map
    (profile: {
      "${profileBase}/${profile}/chrome" = {
        source = pkgs.lib.cleanSourceWith {
          src = "${textfoxyAssets}/chrome";
          filter = path: type: !(type == "regular" && baseNameOf path == "userChrome.css");
        };
        recursive = true;
      };

      "${profileBase}/${profile}/chrome/config.css".text = cfg.configCss;
    })
    profiles);
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.browsers.firefox.enable {
      programs.firefox.profiles = mkProfiles cfg.browsers.firefox.profiles;
      home.file = mkChromeFiles ".mozilla/firefox" cfg.browsers.firefox.profiles;
    })

    (lib.mkIf cfg.browsers.librewolf.enable {
      programs.librewolf.profiles = mkProfiles cfg.browsers.librewolf.profiles;
      home.file = mkChromeFiles ".librewolf" cfg.browsers.librewolf.profiles;
    })
  ]);
}
