{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    prefix = "C-a";
    keyMode = "vi";
    escapeTime = 0;
    historyLimit = 50000;

    sensibleOnTop = true;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      {
        plugin = cpu;
        extraConfig = ''
          # Set status-right BEFORE cpu plugin loads so it can interpolate the format strings
          set -g status-right 'CPU: #{cpu_icon} #{cpu_percentage} | RAM: #{ram_icon} #{ram_percentage} | %a %h-%d %H:%M '
        '';
      }
    ];

    extraConfig = ''
      # Enable extended keys for better key sequence support
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'

      ### Bindings ###

      # Switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # New window and split directory settings
      unbind %
      unbind \"
      bind c new-window -c "~"
      bind \\ split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Auto-resize to favorite settings
      bind L resize-pane -x100
      bind K resize-pane -x120
      bind J resize-pane -x150
    '';
  };
}
