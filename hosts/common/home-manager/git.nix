{ ... }:
{
  programs.git = {
    enable = true;
    userName = "sidharta";
    userEmail = "jeansidharta@gmail.com";
    aliases = {
      lg = "log --graph --format=\"format:%C(auto)%h%C(reset) %C(white)-%C(reset) %C(italic blue)%ad%C(reset) %C(italic cyan)(%ar)%C(reset)%C(auto)%d%C(reset)%n %C(white)⤷%C(reset) %s %C(241)- %aN <%aE>%C(reset)%n%w(0,7,7)%+(trailers:only,unfold)\"";
      s = "status --short";
      a = "add .";
      c = "commit";
      ac = "!sh 'git add . && git commit'";
      ca = "commit --amend";
    };
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
