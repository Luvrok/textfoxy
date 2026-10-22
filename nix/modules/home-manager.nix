inputs:
{ config, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
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

  # the chrome directory with config.css in it. home-manager links every file
  # into the store, and content processes (sidebery, about: pages) resolve
  # userContent.css's imports next to the file it links to: config.css has
  # to be in the same store path, or sidebery gets none of the colors.
  # userChrome.css comes from the profiles' userChrome option instead
  chromeDir = pkgs.runCommand "textfoxy-chrome" { } ''
    cp -r ${textfoxyAssets}/chrome $out
    chmod -R u+w $out
    rm $out/userChrome.css
    cp ${pkgs.writeText "config.css" cfg.configCss} $out/config.css
  '';

  mkChromeFiles = profileBase: profiles: lib.mkMerge (map
    (profile: {
      "${profileBase}/${profile}/chrome" = {
        source = chromeDir;
        recursive = true;
      };
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
