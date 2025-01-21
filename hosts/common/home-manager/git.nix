{ }:
{
  programs.git = {
    enable = true;
    userName = "sidharta";
    userEmail = "jeansidharta@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      core = {
        autocrlf = "input";
        editor = "vim";
      };
      fetch.prune = true;
      push.autoSetupRemote = true;
      safe.directory = "/etc/nixos";
    };
  };
}
