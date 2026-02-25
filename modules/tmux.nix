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
      # Pass focus events through to applications (e.g. Neovim FocusGained/FocusLost)
      set -g focus-events on

      # Enable extended keys for better key sequence support
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'

      ### Bindings ###

      # Smart pane switching with awareness of Vim splits
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

      bind-key -n 'M-h' if-shell "$is_vim" 'send-keys M-h' 'if-shell -F "#{?pane_at_left,,1}" "select-pane -L"'
      bind-key -n 'M-j' if-shell "$is_vim" 'send-keys M-j' 'if-shell -F "#{?pane_at_bottom,,1}" "select-pane -D"'
      bind-key -n 'M-k' if-shell "$is_vim" 'send-keys M-k' 'if-shell -F "#{?pane_at_top,,1}" "select-pane -U"'
      bind-key -n 'M-l' if-shell "$is_vim" 'send-keys M-l' 'if-shell -F "#{?pane_at_right,,1}" "select-pane -R"'

      bind-key -T copy-mode-vi 'M-h' if-shell -F '#{?pane_at_left,,1}' 'select-pane -L'
      bind-key -T copy-mode-vi 'M-j' if-shell -F '#{?pane_at_bottom,,1}' 'select-pane -D'
      bind-key -T copy-mode-vi 'M-k' if-shell -F '#{?pane_at_top,,1}' 'select-pane -U'
      bind-key -T copy-mode-vi 'M-l' if-shell -F '#{?pane_at_right,,1}' 'select-pane -R'

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
