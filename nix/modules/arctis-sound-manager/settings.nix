# Shared preferences. Hosts supply only concrete PipeWire endpoint identifiers.
{ fallbackOutput, fallbackInput }:

{
  # JSON is also valid YAML; keeping one serializer avoids format-specific logic.
  "settings/general_settings.yaml" = builtins.toJSON {
    # Audio endpoints and automatic fallback.
    external_output_device = fallbackOutput;
    generic_input_device = fallbackInput;
    generic_output_device = fallbackOutput;
    micro_alt_source = fallbackInput;
    micro_autoswitch = 1;
    micro_input_source = "__auto__";

    # Auto-detect the headset; do not pin a host-specific USB bus/port path.
    preferred_device = "";
    redirect_audio_on_connect_channel = 0;
    redirect_audio_on_disconnect = true;
    redirect_audio_on_disconnect_device = fallbackOutput;

    # DAC display.
    oled_custom_display = false;
    oled_display_order = [
      "sonar_mode"
      "profile"
      "eq"
      "eq_chat"
      "weather"
    ];
    oled_font_battery = 12;
    oled_font_mic = 12;
    oled_font_time = 12;
    oled_font_weather_temp = 20;
    oled_screen_timeout = 10;
    oled_show_battery = true;
    oled_show_eq = false;
    oled_show_eq_chat = false;
    oled_show_mic_status = false;
    oled_show_profile = false;
    oled_show_sonar_mode = false;
    oled_show_weather_city = false;
    oled_time_24h = false;

    # Tray and weather preferences.
    systray_icon_color = 1;
    systray_show_battery = true;
    weather_city_display = "Denver";
    weather_enabled = true;
    weather_lat = 39.7392364;
    weather_location = "Denver";
    weather_lon = -104.984862;
    weather_units = "celsius";
  };

  # Arctis Nova Pro Wireless hardware preferences (USB vendor/product ID).
  "settings/1038_12e0.yaml" = builtins.toJSON {
    bluetooth_auto_mute = 0;
    bluetooth_power_status = 0;
    dial_interface = -1;
    gain = 2;
    line_out = 2;
    line_out_stream_aux_volume = 100;
    line_out_stream_main_left_volume = 100;
    line_out_stream_main_right_volume = 100;
    mic_led_brightness = 10;
    mic_side_tone = 0;
    mic_volume = 10;
    noise_cancelling = 0;
    pm_shutdown = 5;
    transparent_level = 5;
    wireless_mode = 0;
  };

  "routing_overrides.json" = builtins.toJSON {
    # Applications assigned to Arctis virtual channels.
    "Big Walk.exe" = "Arctis_Game";
    "Chromium|.Discord-wrapped" = "Arctis_Media";
    "Chromium|steamwebhelper" = "Arctis_Media";
  };

  # EQ mode, presets and generated PipeWire filters remain owned by ASM.
  ".language" = "en";
  "telemetry.yaml" = builtins.toJSON { consent = false; };
}
