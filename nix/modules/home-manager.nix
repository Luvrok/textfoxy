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

  # the icon sets in icons.css are switched by these prefs
  iconPrefs = {
    "shyfox.enable.ext.mono.toolbar.icons" = cfg.config.icons.toolbar.extensions.enable;
    "shyfox.enable.ext.mono.context.icons" = cfg.config.icons.context.extensions.enable;
    "shyfox.enable.context.menu.icons" = cfg.config.icons.context.firefox.enable;
  };

  mkProfiles = browserProfiles: lib.mkMerge (map
    (profile: {
      ${profile} = {
        settings = iconPrefs;
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
      # home-manager's own path: ~/.mozilla/firefox, or ~/.config/mozilla/firefox
      # since home.stateVersion 26.05
      home.file = mkChromeFiles config.programs.firefox.profilesPath cfg.browsers.firefox.profiles;
    })

    (lib.mkIf cfg.browsers.librewolf.enable {
      programs.librewolf.profiles = mkProfiles cfg.browsers.librewolf.profiles;
      home.file = mkChromeFiles config.programs.librewolf.profilesPath cfg.browsers.librewolf.profiles;
    })
  ]);
}
