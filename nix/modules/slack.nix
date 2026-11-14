{
  den.aspects.slack.provides.to-hosts.darwin.homebrew.casks = [ "slack" ];

  den.aspects.slack.hmLinux = { pkgs, ... }: {
    home.packages = [
      (pkgs.slack.overrideAttrs (old: {
        # Slack 4.51.180 creates native notifications without retaining their JS
        # wrappers. Electron GC then disconnects their click delegates, leaving dead
        # View buttons in the notification center. Restore Slack's existing bounded
        # retention list and cleanup helper; remove once Slack fixes this upstream.
        # Electron requires applications to retain their Notification objects:
        # https://github.com/electron/electron/issues/16922
        # These minified names are version-specific: fail on source drift at upgrades.
        postInstall = (old.postInstall or "") + ''
          archive="$out/lib/slack/resources/app.asar"
          appDir=$(mktemp -d)
          unpacked=$(asar list --is-pack "$archive" | sed -n 's|^unpack : /|**/|p' | paste -sd, -)
          asar extract "$archive" "$appDir"

          # Mf retains wrappers, G6 evicts beyond Slack's existing 10,000-entry cap,
          # and W6 releases wrappers on click, close, reply, action, or failure.
          substituteInPlace "$appDir/dist/main.bundle.cjs" \
            --replace-fail 'vG(y,P=>{if(EG(P)' 'Mf.push(y),G6(),vG(y,P=>{if(EG(P)' \
            --replace-fail '()=>$.vF.debug(`Notification ''${y.options.id} cleaned up`)' \
              '()=>{W6(y);$.vF.debug(`Notification ''${y.options.id} cleaned up`)}'

          # Preserve which resources/native modules live outside the archive.
          asar pack "$appDir" "$archive" --unpack "{$unpacked}"
          rm -r "$appDir"
        '';
      }))
    ];
  };
}
