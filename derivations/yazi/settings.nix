{ pkgs, ... }:
let
  socat = "${pkgs.socat}/bin/socat";
in
{
  programs.yazi.settings = {
    log = {
      enabled = false;
    };
    manager = {
      show_hidden = false;
      sort_dir_first = true;
      show_symlink = true;
    };
    preview = {
      wrap = "yes";
      tab_size = 4;
      max_width = 1000;
      max_height = 1000;
    };
    tasks = {
      micro_workers = 3;
      macro_workers = 3;
      image_alloc = 4 * 1024 * 1024;
    };
    opener = {
      add-sub = [
        {
          run = ''
            echo sub-add "'$0'" | ${socat} - /tmp/mpv.sock
          '';
          desc = "Add sub to MPV";
        }
      ];
    };
    open.prepend_rules = [
      {
        name = "*.{ass,srt,ssa,sty,sup,vtt}";
        use = [
          "add-sub"
          "edit"
        ];
      }
    ];
  };
}
