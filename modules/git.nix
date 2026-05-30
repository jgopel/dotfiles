{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    lfs.enable = true;

    settings = {
      user = {
        name = "Jonathan Gopel";
        email = "jgopel@gmail.com";
      };

      core = {
        autocrlf = false;
        whitespace = "blank-at-eol,space-before-tab,tab-in-indent,-blank-at-eof,tabwidth=8";
        logAllRefUpdates = true;
        pager = "less";
      };

      init.defaultBranch = "main";
      help.autocorrect = "prompt";
      color.ui = true;

      status = {
        showuntrackedfiles = "normal";
        submodulesummary = true;
      };

      merge = {
        ff = "no";
        conflictstyle = "diff3";
        tool = "nvimdiff";
      };

      pull.ff = "only";
      push.default = "simple";
      log.date = "rfc-local";

      diff = {
        indentHeuristic = true;
        submodule = "log";
        colorMoved = "zebra";
      };

      fetch.prune = true;
      clangFormat.extension = "c,cc,cpp,h,hpp";

      alias = {
        ack = ''-c color.grep.linenumber="bold yellow" -c color.grep.filename="bold green" -c color.grep.match="reverse yellow" grep --break --heading --line-number'';
        cane = "commit --amend --no-edit";
        co = "checkout";
        default-branch = ''!git symbolic-ref refs/remotes/upstream/HEAD --short 2> /dev/null || git symbolic-ref refs/remotes/origin/HEAD --short 2> /dev/null'';
        delete-merged = ''!git branch --merged $(git default-branch) | egrep -v "(^\\*|master|main)" | xargs git branch -d 2> /dev/null'';
        fa = ''!git fetch --all --prune --tags --jobs=$(nproc)'';
        git = ''!sh -c 'echo You are an idiot' && git'';
        graph = "log --color --graph --decorate --oneline";
        nwadd = ''!git diff -w --no-color | git apply --cached --ignore-whitespace'';
        push-ci = "push -o ci.variable=PUSH_RUN_CI=1";
        rb = "rebase --rebase-merges --autosquash --autostash --interactive";
        root = "rev-parse --show-toplevel";
        todo = ''! git --no-pager diff --unified=0 $(git default-branch) --color-words --no-color | grep 'TODO' | git grep -f - --fixed-strings --line-number 2> /dev/null'';
        wip = ''commit -m "wip"'';
      };
    };

    ignores = [
      "*.swp"
      "*.swo"
      "*.swn"
      "cscope.in.out"
      "cscope.out"
      "cscope.po.out"
      "tags"
      "__pycache__/"
      ".ycm_extra_conf.py"
      "compile_commands.json"
      ".clangd/"
      ".cache/"
      "*.sync-conflict-*.lock"
      ".syncthing.*.tmp"
    ];
  };
}
