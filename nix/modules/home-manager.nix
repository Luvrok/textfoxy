inputs:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (builtins) baseNameOf;
  cfg = config.textfoxy;
  textfoxyAssets = inputs.self.packages.${system}.default;

  extensionList = lib.optionals cfg.config.tabs.vertical.sidebery.enable [
    inputs.firefox-addons.packages.${system}.sidebery
  ];

  mkProfiles = lib.mkMerge (map
    (profile: {
      ${profile} = {
        extraConfig = builtins.readFile "${textfoxyAssets}/user.js";
        extensions.packages = extensionList;
        containersForce = true;
        userChrome = lib.mkBefore (builtins.readFile "${textfoxyAssets}/chrome/userChrome.css");
      };
    })
    cfg.profiles);

  mkChromeFiles = profileBase: lib.mkMerge (map
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
    cfg.profiles);
in
{
  imports = [
    ./options.nix
    (lib.mkChangedOptionModule [ "textfoxy" "profile" ] [ "textfoxy" "profiles" ] (
      config:
      let
        profile = lib.getAttrFromPath [ "textfoxy" "profile" ] config;
      in
      [ profile ]
    ))
  ];

  options.textfoxy = {
    profiles = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "List of browser profiles to apply the textfoxy configuration to";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf (cfg.browser == "firefox") {
      programs.firefox = {
        enable = true;
        profiles = mkProfiles;
      };

      home.file = mkChromeFiles ".mozilla/firefox";
    })

    (lib.mkIf (cfg.browser == "librewolf") {
      programs.librewolf = {
        enable = true;
        profiles = mkProfiles;
      };

      home.file = mkChromeFiles ".librewolf";
    })
  ]);
}
