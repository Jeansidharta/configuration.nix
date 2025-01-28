{
  inputs = {
    yazi.url = "github:sxyazi/yazi";
  };
  outputs =
    {
      self,
      yazi,
    }:
    {
      homeManagerModules.default =
        { pkgs, ... }:
        {
          imports = [
            # TODO - add flavor
            ./default-keymaps.nix
            ./keymaps.nix
            ./settings.nix
            ./plugins.nix
          ];
          home.packages = [
            # Required for yazi to show file metadata.
            pkgs.exiftool
          ];
          programs.yazi = {
            enable = true;
            enableZshIntegration = true;
            initLua = builtins.readFile ./init.lua;
          };
        };
      overlays = yazi.overlays;
    };
}
