{
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.rycee) firefox-addons;
  withBase =
    extra:
    (
      extra
      // {
        settings = {
          "extensions.autoDisableScopes" = 0;
          "browser.aboutConfig.showWarning" = false;
          "browser.translations.automaticallyPopup" = false;
          "signon.rememberSignons" = false;
        }
        // (if (extra ? settings) then extra.settings else { });
        extensions.packages = [
          firefox-addons.bitwarden
        ]
        ++ (if (extra ? extensions && extra.extensions ? packages) then extra.extensions.packages else [ ]);
      }
    );
in

{
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    profiles.default = withBase {
      isDefault = true;
      name = "default";
      id = 0;
      extensions.packages = [
        firefox-addons.dearrow
        firefox-addons.ublock-origin
        firefox-addons.sponsorblock
      ];
    };
    profiles.LsbJean = withBase {
      name = "LsbJean";
      id = 1;
      settings = {
        "browser.startup.homepage" =
          "https://mon2.oryonti.com/icingaweb2/dashboard|https://mail.google.com/mail/u/0/";
      };
    };
    profiles.LsbProxy = withBase {
      name = "LsbProxy";
      id = 2;
      settings = {
        "network.proxy.socks" = "localhost";
        "network.proxy.socks_port" = 8080;
        "network.proxy.type" = 1;
      };
    };
  };
}
