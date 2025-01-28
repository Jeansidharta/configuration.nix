{ ... }:
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    # TODO - add theme
    settings = {
      log = {
        enabled = false;
      };
      manager = {
        show_hidden = false;
        sort_dir_first = true;
      };
    };
    keymap = {
      input.keymap = [
      ];
      manager.keymap = [
      ];
    };
  };
}
