inputs:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkOption mkPackageOption types;
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.types) listOf path str;
  inherit (lib.trivial) boolToString;

  inherit (pkgs.stdenv.hostPlatform) system;
  wrapTextfoxy = inputs.self.lib.${system}.wrapTextfoxy;

  cfg = config.textfoxy;

  selectedPackage =
    if cfg.browser == "librewolf"
    then cfg.librewolf.package
    else cfg.firefox.package;
in
{
  imports = [ ./options.nix ];

  options.textfoxy = {
    firefox.package = mkPackageOption pkgs "firefox-unwrapped" { };
    librewolf.package = mkPackageOption pkgs "librewolf-unwrapped" { };

    extraPoliciesFiles = mkOption {
      type = listOf path;
      default = [ ];
      description = "Custom policy.json files passed; see 'about:policies'.";
    };

    extraPrefsFiles = mkOption {
      type = listOf path;
      default = [ ];
      description = "Custom autoconfig.js files passed";
    };

    extraUserChrome = mkOption {
      type = str;
      default = "";
      description = "Custom userChrome.css appended to the hooked textfoxy file.";
    };

    extraUserContent = mkOption {
      type = str;
      default = "";
      description = "Custom userContent.css appended to the hooked textfoxy file.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      let
        policies = {
          ExtensionSettings =
            optionalAttrs (cfg.config.tabs.vertical.enable && cfg.config.tabs.vertical.sidebery.enable)
              {
                # Declarative installation of sidebery
                "{3c078156-979c-498b-8990-85f7987dd929}" = {
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
                  installation_mode = "force_installed";
                  default_area = "menupanel";
                };
              };
        };

        preferences =
          let
            icons = config.textfoxy.config.icons;
          in
          ''
            pref("shyfox.enable.ext.mono.toolbar.icons", ${boolToString icons.toolbar.extensions.enable});
            pref("shyfox.enable.ext.mono.context.icons", ${boolToString icons.context.extensions.enable});
            pref("shyfox.enable.context.menu.icons", ${boolToString icons.context.firefox.enable});
          '';

      in
      [
        (wrapTextfoxy selectedPackage {
          inherit (cfg)
            extraPoliciesFiles
            extraPrefsFiles
            extraUserChrome
            extraUserContent
            configCss
            ;

          extraPolicies = policies;
          extraPrefs = preferences;
        })
      ];
  };
}
