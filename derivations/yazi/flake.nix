{
  inputs = {
    yazi.url = "github:sxyazi/yazi";
    plugins = {
      flake = false;
      url = "github:yazi-rs/plugins";
    };
  };
  outputs =
    {
      self,
      yazi,
      plugins,
    }:
    {
      homeManagerModules.default =
        { pkgs, ... }:
        {
          imports = [
            # TODO - add flavor
            ./keymaps.nix
            ./settings.nix
          ];
          home.packages = [
            # Required for yazi to show image metadata.
            pkgs.exiftool
          ];
          programs.yazi = {
            enable = true;
            enableZshIntegration = true;
            initLua = builtins.readFile ./init.lua;
            plugins = {
              max-preview = "${plugins.outPath}/max-preview.yazi";
              diff  = "${plugins.outPath}/diff.yazi";
            };
          };
        };
      overlays = yazi.overlays;
    };
}
