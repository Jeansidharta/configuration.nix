{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      character = {
        success_symbol = "[\\[❯\\]](bold green)";
        error_symbol = "[\\[✖\\]](bold red)";
        vimcmd_symbol = "[\\[N\\]](bold purple)";
      };
      memory_usage = {
        disabled = false;
        threshold = 76;
      };
      status.disabled = false;
      sudo.disabled = false;
    };
  };
}
