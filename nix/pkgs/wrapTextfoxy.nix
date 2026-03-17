{
  lib,
  wrapFirefox,
  runCommandLocal,
}:
browser:
{
  configCss ? "",
  extraUserChrome ? "",
  extraUserContent ? "",
  ...
}@args:
let

  textfoxyChrome =
    runCommandLocal "textfoxy-chrome"
      {
        inherit configCss extraUserChrome extraUserContent;
        passAsFile = [
          "configCss"
          "extraUserChrome"
          "extraUserContent"
        ];

        src = ./../../chrome;
      }
      ''
        mkdir -p "$out"
        cp -r "$src/icons" "$out/icons"

        ### USERCHROME
        cat "$src/overwrites.css" >> "$out/userChrome.css"
        cat "$src/userChrome.css" >> "$out/userChrome.css"
        cat "$src/sidebar.css" >> "$out/userChrome.css"
        cat "$src/browser.css" >> "$out/userChrome.css"
        cat "$src/findbar.css" >> "$out/userChrome.css"
        cat "$src/navbar.css" >> "$out/userChrome.css"
        cat "$src/urlbar.css" >> "$out/userChrome.css"
        sed "s|./icons|$out/icons|g" "$src/icons.css" >> "$out/userChrome.css"
        cat "$src/menus.css" >> "$out/userChrome.css"
        cat "$src/tabs.css" >> "$out/userChrome.css"

        cat "$src/defaults.css" >> "$out/userChrome.css"
        cat "$configCssPath" >> "$out/userChrome.css"
        cat "$extraUserChromePath" >> "$out/userChrome.css"

        ### USERCONTENT
        cat "$src/content/sidebery.css" >> "$out/userContent.css"
        cat "$src/content/newtab.css" >> "$out/userContent.css"
        cat "$src/content/about.css" >> "$out/userContent.css"

        cat "$src/defaults.css" >> "$out/userContent.css"
        cat "$configCssPath" >> "$out/userContent.css"
        cat "$extraUserContentPath" >> "$out/userContent.css"
      '';

  configScript = ''
    // TEXTFOXY GENERATED CONFIG
    const { classes: Cc, interfaces: Ci } = Components;
    const { FileUtils } = ChromeUtils.importESModule(
      "resource://gre/modules/FileUtils.sys.mjs"
    );

    var updated = false;

    var chromeDir = Services.dirsvc.get("ProfD", Ci.nsIFile);
    chromeDir.append("chrome");

    var textfoxyChrome = new FileUtils.File("@textfoxyChrome@");
    var userChrome = new FileUtils.File("@textfoxyChrome@/userChrome.css");
    var userContent = new FileUtils.File("@textfoxyChrome@/userContent.css");

    var hashFile = chromeDir.clone();
    hashFile.append(textfoxyChrome.displayName);

    if (!chromeDir.exists()) {
      chromeDir.create(Ci.nsIFile.DIRECTORY_TYPE, FileUtils.PERMS_DIRECTORY);
      userChrome.copyTo(chromeDir, "userChrome.css");
      userContent.copyTo(chromeDir, "userContent.css");
      updated = true;
    } else if (!hashFile.exists()) {
      chromeDir.remove(true);
      userChrome.copyTo(chromeDir, "userChrome.css");
      userContent.copyTo(chromeDir, "userContent.css");
      updated = true;
    }

    if (updated) {
      hashFile.create(Ci.nsIFile.NORMAL_FILE_TYPE, 0o644);
      var appStartup = Cc["@mozilla.org/toolkit/app-startup;1"]
        .getService(Ci.nsIAppStartup);
      appStartup.quit(Ci.nsIAppStartup.eForceQuit | Ci.nsIAppStartup.eRestart);
    }

    pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
    pref("svg.context-properties.content.enabled", true);
    pref("layout.css.has-selector.enabled", true);
    // END TEXTFOXY AUTOCONFIG
  '';

in
wrapFirefox browser (
  lib.removeAttrs args [
    "configCss"
    "extraUserChrome"
    "extraUserContent"
  ]
  // {
    pname = args.pname or "textfoxy";
    extraPrefs = configScript + (args.extraPrefs or "");
  }
)
