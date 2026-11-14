{
  den.aspects.macos.keyboard = {
    provides.to-hosts.darwin.homebrew.casks = [ "karabiner-elements" ];

    homeManager =
      { pkgs, ... }:
      let
        terminals = [
          "^com\\.mitchellh\\.ghostty$"
          "^com\\.apple\\.Terminal$"
        ];
        outsideTerminal = {
          type = "frontmost_application_unless";
          bundle_identifiers = terminals;
        };
        inTerminal = {
          type = "frontmost_application_if";
          bundle_identifiers = terminals;
        };
        # Only application/navigation rules opt into preserving Shift.
        # Global commands require exact chords; extra modifiers pass through.
        shortcut = key: modifiers: optional: to: conditions: {
          type = "basic";
          from = {
            key_code = key;
            modifiers = {
              mandatory = modifiers;
              optional = [ "caps_lock" ] ++ optional;
            };
          };
          inherit to conditions;
        };
        appShortcut =
          key:
          shortcut key [ "control" ] [ "shift" ]
            [
              {
                key_code = key;
                modifiers = [ "left_command" ];
              }
            ]
            [ outsideTerminal ];
        wordShortcut =
          key:
          shortcut key [ "control" ] [ "shift" ]
            [
              {
                key_code = key;
                modifiers = [ "left_option" ];
              }
            ]
            [ outsideTerminal ];
      in
      {
        xdg.configFile."karabiner/karabiner.json".text = builtins.toJSON {
          global = {
            check_for_updates_on_startup = false;
            show_in_menu_bar = true;
          };
          profiles = [
            {
              name = "Linux shortcuts and OmniWM";
              selected = true;
              # Keep modifier mappings in the same complex-modification pass.
              # Synthesized Command events must not be remapped a second time.
              complex_modifications.rules = [
                {
                  description = "Built-in Ctrl/Super/Alt order and Caps Lock as Escape";
                  manipulators =
                    map
                      (keys: {
                        type = "basic";
                        from = {
                          key_code = keys.from;
                          modifiers.optional = [ "any" ];
                        };
                        to = [ { key_code = keys.to; } ];
                        conditions = [
                          {
                            type = "device_if";
                            identifiers = [ { is_built_in_keyboard = true; } ];
                          }
                        ];
                      })
                      [
                        {
                          from = "left_option";
                          to = "right_command";
                        }
                        {
                          from = "left_command";
                          to = "left_option";
                        }
                        {
                          from = "right_option";
                          to = "right_command";
                        }
                        {
                          from = "right_command";
                          to = "right_option";
                        }
                        {
                          from = "caps_lock";
                          to = "escape";
                        }
                      ];
                }
                {
                  description = "External keyboard Super is Right Command; preserve PC modifier order";
                  manipulators = [
                    {
                      type = "basic";
                      from = {
                        key_code = "left_command";
                        modifiers.optional = [ "any" ];
                      };
                      to = [ { key_code = "right_command"; } ];
                      conditions = [
                        {
                          type = "device_unless";
                          identifiers = [ { is_built_in_keyboard = true; } ];
                        }
                      ];
                    }
                  ];
                }
                {
                  description = "Hyprland terminal, region screenshot, and lock shortcuts";
                  manipulators = [
                    (shortcut "t" [ "control" "option" ] [ ]
                      [ { shell_command = "/usr/bin/open -na '${pkgs.ghostty-bin}/Applications/Ghostty.app'"; } ]
                      [ ]
                    )
                    (shortcut "s" [ "right_command" "shift" ] [ ]
                      [ { shell_command = "/usr/sbin/screencapture -i -c"; } ]
                      [ ]
                    )
                    (shortcut "b" [ "right_command" ] [ ]
                      [
                        {
                          key_code = "q";
                          modifiers = [
                            "left_control"
                            "left_command"
                          ];
                        }
                      ]
                      [ ]
                    )
                  ];
                }
                {
                  description = "Linux application shortcuts without changing physical Control or Super";
                  manipulators =
                    map appShortcut [
                      "a"
                      "c"
                      "d"
                      "f"
                      "g"
                      "l"
                      "n"
                      "o"
                      "p"
                      "q"
                      "r"
                      "s"
                      "t"
                      "v"
                      "w"
                      "x"
                      "z"
                      "0"
                      "hyphen"
                      "equal_sign"
                    ]
                    ++ map wordShortcut [
                      "left_arrow"
                      "right_arrow"
                      "delete_or_backspace"
                      "delete_forward"
                    ]
                    ++ [
                      (shortcut "y" [ "control" ] [ ]
                        [
                          {
                            key_code = "z";
                            modifiers = [
                              "left_command"
                              "left_shift"
                            ];
                          }
                        ]
                        [ outsideTerminal ]
                      )
                      (shortcut "home" [ ] [ "shift" ]
                        [
                          {
                            key_code = "left_arrow";
                            modifiers = [ "left_command" ];
                          }
                        ]
                        [ outsideTerminal ]
                      )
                      (shortcut "end" [ ] [ "shift" ]
                        [
                          {
                            key_code = "right_arrow";
                            modifiers = [ "left_command" ];
                          }
                        ]
                        [ outsideTerminal ]
                      )
                      (shortcut "home" [ "control" ] [ "shift" ]
                        [
                          {
                            key_code = "up_arrow";
                            modifiers = [ "left_command" ];
                          }
                        ]
                        [ outsideTerminal ]
                      )
                      (shortcut "end" [ "control" ] [ "shift" ]
                        [
                          {
                            key_code = "down_arrow";
                            modifiers = [ "left_command" ];
                          }
                        ]
                        [ outsideTerminal ]
                      )
                      (shortcut "tab" [ "option" ] [ "shift" ]
                        [
                          {
                            key_code = "tab";
                            modifiers = [ "left_command" ];
                          }
                        ]
                        [ ]
                      )
                    ];
                }
                {
                  description = "Terminal copy/paste only; Ctrl-C/D/Z, tmux, and Neovim stay native";
                  manipulators =
                    map
                      (
                        key:
                        shortcut key [ "control" "shift" ] [ ]
                          [
                            {
                              key_code = key;
                              modifiers = [ "left_command" ];
                            }
                          ]
                          [ inTerminal ]
                      )
                      [
                        "c"
                        "v"
                      ];
                }
              ];
            }
          ];
        };
      };
  };
}
