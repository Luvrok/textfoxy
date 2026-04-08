```
 _            _    __
| |_ _____  _| |_ / _| _____  ___   _
| __/ _ \ \/ / __| |_ / _ \ \/ / | | |
| ||  __/>  <| |_|  _| (_) >  <| |_| |
 \__\___/_/\_\\__|_|  \___/_/\_\\__, |
                                |___/
```

A fork of textfox, a Firefox theme inspired by Spotify TUI, with LibreWolf and Sidebery support. Firefox is supported as well.

## Preview

![image](https://github.com/Luvrok/textfoxy/blob/main/misc/vertical-tabs.png)

![image](https://github.com/Luvrok/textfoxy/blob/main/misc/horizontal-tabs.png)

> [!NOTE]
> The color scheme used in the pictures is [Rosé Pine Moon](https://github.com/rose-pine/firefox).
> `textfox` tries to not hard code any colors, [Firefox Color extension](https://addons.mozilla.org/en-US/firefox/addon/firefox-color/) is the
> recommended approach to coloring Firefox with `textfoxy`.

## Prerequisites

- Sidebery (optional)

## Installation

### Installation script

1. Download/clone the repo.
2. Inside the download run `sh tf-install.sh` and follow the script
   instructions.

> [!IMPORTANT]
> This script automates file writes, use with caution.

> [!NOTE]
> The installation script copies the contents of the repo's `chrome` directory to the specified path.
> the path specified, this way your `config.css` or any other `css`-files not
> part of the repo will be kept.

### Manual

1. Download the files
2. Go to `about:profiles`
3. Find the names of target profiles (ex: `Profile: Default`)
4. Open the profile's root directory
5. Move the `chrome` directory and `user.js` there.
6. Restart Firefox

### Nix

This repo includes a Nix flake that exposes a home-manager module that installs textfoxy and sidebery.

To enable the module, add the repo as a flake input, import the module, and enable textfoxy.

<details><summary>Install using your home-manager module defined within your `nixosConfigurations`:</summary>

```nix

  # flake.nix

  {

      inputs = {
         # ---Snip---
         home-manager = {
           url = "github:nix-community/home-manager";
           inputs.nixpkgs.follows = "nixpkgs";
         };

         textfoxy.url = "github:Luvrok/textfoxy";
         # ---Snip---
      }

      outputs = {nixpkgs, home-manager, ...} @ inputs: {
          nixosConfigurations.HOSTNAME = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
            home-manager.nixosModules.home-manager
              {
               # Must pass in inputs so we can access the module
                home-manager.extraSpecialArgs = {
                  inherit inputs;
                };
              }
           ];
        };
     }
  }
```
```nix

# home.nix

imports = [ inputs.textfoxy.homeManagerModules.default ];

textfoxy = {
    enable = true;
    # Replace with the names of profiles, defined in home-manager, or find existing ones in `about:profiles`
    browsers = {
      librewolf = {
        enable = true;
        profiles = ["life" "work"];
      };

      firefox = {
        enable = true;
        profiles = ["life" "work"];
      };
    };
    config = {
        # Optional config
    };
};
```
</details>

<details><summary>Install using `home-manager.lib.homeManagerConfiguration`:</summary>

```nix

  # flake.nix

  {
    inputs = {
       # ---Snip---
       home-manager = {
         url = "github:nix-community/home-manager";
         inputs.nixpkgs.follows = "nixpkgs";
       };

       textfoxy.url = "github:Luvrok/textfoxy";
       # ---Snip---
    }

    outputs = {nixpkgs, home-manager, textfoxy ...}: {
        homeConfigurations."user@hostname" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;

            modules = [
                textfoxy.homeManagerModules.default
                # ...
            ];
        };
    };
  }
```
  ```nix

  # home.nix

  textfoxy = {
      enable = true;
      # Replace with the names of profiles, defined in home-manager, or find existing ones in `about:profiles`
      browsers = {
        librewolf = {
          enable = true;
          profiles = ["life" "work"];
        };

        firefox = {
          enable = true;
          profiles = ["life" "work"];
        };
      };
      config = {
          # Optional config
      };
  };
  ```
</details>

<details><summary>Configuration options:</summary>

All configuration options are optional and can be set as this example shows (real default values [can be found below](#defaults)):

```nix

  textfoxy = {
      enable = true;
      # Replace with the names of profiles, defined in home-manager, or find existing ones in `about:profiles`
      browsers = {
        librewolf = {
          enable = true;
          profiles = ["life" "work"];
        };

        firefox = {
          enable = true;
          profiles = ["life" "work"];
        };
      };
      config = {
        background = {
          color = "#123456";
        };
        border = {
          color = "#654321";
          width = "4px";
          transition = "1.0s ease";
          radius = "3px";
        };
        displayWindowControls = true;
        displayNavButtons = true;
        displayUrlbarIcons = true;
        displaySidebarTools = false;
        displayTitles = false;
        newtabLogo = "   __            __  ____          \A   / /____  _  __/ /_/ __/___  _  __\A  / __/ _ \\| |/_/ __/ /_/ __ \\| |/_/\A / /_/  __/>  </ /_/ __/ /_/ />  <  \A \\__/\\___/_/|_|\\__/_/  \\____/_/|_|  ";
        font = {
          family = "Fira Code";
          size = "15px";
          accent = "#654321";
        };
        tabs = {
          horizontal.enable = true;
          vertical.enable = true;
          vertical.sidebery.enable = true;
          vertical.sidebery.margin = "1.0rem";
        };
        navbar = {
          margin = "8px 8px 2px";
          padding = "4px";
        };
        bookmarks = {
          alignment = "left";
        };
        icons = {
          toolbar.extensions.enable = true;
          context.extensions.enable = true;
          context.firefox.enable = true;
        };
        textTransform = "uppercase";
        extraConfig = "/* custom css here */";
      };
  };
```
</details>

### Sidebery

Sidebery CSS is provided from `content/sidebery` (applied as content to
the sidebery url). If you have any pre-existing css set from within the sidebery
settings, they might clash or make it so that the sidebery style does not match
the example.

#### Settings

The theme was made using a reset sidebery config, so there should not be
anything crazy needed here, notable settings being set is using the **plain**
theme and **firefox** color scheme. If you want to you can import the sidebery
settings provided.

> [!IMPORTANT]
> **Importing sidebery settings overwrites your current settings, do this at
> your own risk.**

## Customization

The icon configuration utilizes code that is originally from ShyFox, therefore
the same settings are used (these can be set in about:config).
| Setting | true | false (default) |
| -------------------------------------- | --------------------------------------------------------------------- | ------------------------- |
| `shyfox.enable.ext.mono.toolbar.icons` | Supported extensions get monochrome icons as toolbar buttons | Standard icons used |
| `shyfox.enable.ext.mono.context.icons` | Supported extensions get monochrome icons as context menu items | Standard icons used |
| `shyfox.enable.context.menu.icons` | Many context menu items get icons | No icons in context menus |

### CSS configurations
The theme ships with `defaults.css`, this file can be overridden by creating a
`config.css` inside the chrome directory.

#### Defaults
```css
:root {
  --tf-font-family: "SF Mono", Consolas, monospace; /* Font family of config */
  --tf-font-size: 14px; /* Font size of config */
  --tf-accent: var(--toolbarbutton-icon-fill); /* Accent color used, eg: color when hovering a container  */
  --tf-bg: var(--lwt-accent-color, -moz-dialog); /* Background color of all elements, tab colors derive from this */
  --tf-border: var(--arrowpanel-border-color, --toolbar-field-background-color); /* Border color when not hovered */
  --tf-border-transition: 0.2s ease; /* Smooth color transitions for borders */
  --tf-border-width: 2px; /* Width of borders */
  --tf-rounding: 0px; /* Border radius used through out the config */
  --tf-margin: 0.8rem; /* Margin used between elements in sidebery */
  --tf-text-transform: none; /* Text transform to use */
  --tf-display-horizontal-tabs: none; /* If horizontal tabs should be shown, none = hidden, block = shown */
  --tf-display-window-controls: none; /* If the window controls should be shown (won't work with sidebery and hidden horizontal tabs), none = hidden, flex = shown */ 
  --tf-display-nav-buttons: none; /* If the navigation buttons (back, forward) should be shown, none = hidden, flex = shown */
  --tf-display-urlbar-icons: none; /* If the icons inside the url bar should be shown, none = hidden, flex = shown */
  --tf-display-sidebar-tools: flex; /* If the "Customize sidebar" button on the sidebar should be shown, none = hidden, flex = shown */ 
  --tf-display-titles: flex; /* If titles (tabs, navbar, main etc.) should be shown, none = hidden, flex = shown */
  --tf-newtab-logo: "   __            __  ____          \A   / /____  _  __/ /_/ __/___  _  __\A  / __/ _ \\| |/_/ __/ /_/ __ \\| |/_/\A / /_/  __/>  </ /_/ __/ /_/ />  <  \A \\__/\\___/_/|_|\\__/_/  \\____/_/|_|  ";
  --tf-navbar-margin: 8px 8px 2px; /* navbar margin */
  --tf-navbar-padding: 4px; /* navbar padding */
  --tf-bookmarks-alignment: center; /* alignment of bookmarks in the bookmarks toolbar (if you have many bookmarks, left is recommended) */
}

```

### Recipes

Here are some example changes that you can do to achieve different looks.

#### Swap positions of tabs and window controls when using horizontal tabs
```css
/* path: chrome/config.css */
:root {
  --tf-display-horizontal-tabs: inline-flex;
  --tf-display-window-controls: flex;
}
```

#### Rounded borders
```css
/* path: chrome/config.css */
:root {
  --tf-rounding: 4px;
}
```

#### Align bookmarks to the left
```css
/* path: chrome/config.css */
:root {
  --tf-bookmarks-alignment: left;
}
```

#### Adjust title margins

The titles (e.g. "tabs", "navbar", "main") are `::before` pseudo-elements positioned on the border of each container. Override the margin per selector to reposition them.

```css
/* path: chrome/config.css */

/* main content area title */
#tabbrowser-tabbox::before {
  margin: -1.75rem 0rem !important;
}

/* navbar title */
#nav-bar::before {
  margin: -16px 8px !important;
}

/* bookmarks bar title */
#PersonalToolbar::before {
  margin: -1.25rem 0.4rem !important;
}

/* sidebar title */
#sidebar-box::before {
  margin: -0.85rem 0.85rem !important;
}

/* vertical tabs title */
box#vertical-tabs::before {
  margin: -1.75rem .4rem !important;
}

/* horizontal tabs title */
#TabsToolbar::before {
  margin: -1rem .75rem !important;
}

/* findbar title */
findbar::before {
  margin: -1.75rem .75rem !important;
}
```

#### Do you have a banger recipe?
Feel free to open a PR and add it here!

## Acknowledgements

[Naezr](https://github.com/Naezr) - Icon logic and some sidebery logic.
[textfox](https://github.com/adriankarlen/textfox) - original textfox
