#/bin/bash
# Crontab {{{

# Run offlineimap every 5min
jobs=(
  "*/5 * * * * offlineimap"
)

if [ ${#array[*]} -gt 0 ]; then
  e_header "Adding crontabs"

  for idx in ${!jobs[*]}; do
    local job="${jobs[$idx]}"
    if [ ! "$(crontab -l | grep -Fx "$job")" ]; then
      crontab -l | { cat; echo "$job"; } | crontab -
      e_notify "Adding cron job: $job"
    fi
  done
fi

# }}}
# VLC {{{
config="$HOME/.config/vlc/vlcrc"

if [ -e "$config" ]; then
  e_header "Configuring VLC"

  e_notify "Enable Minimal View" \
    $(sed -iq 's/^\(qt-minimal-view=\).*$/\11/' "$config")
  e_notify "Disable Privacy Ask" \
    $(sed -iq 's/^\(qt-privacy-ask=\).*$/\10/' "$config")
  e_notify "Set Volume to 400%" \
    $(sed -iq 's/^\(volume=\).*$/\1400/' "$config")
fi

# }}}
# qBittorrent {{{

config="$HOME/.config/qBittorrent/qBittorrent.conf"

if [ -e "$config" ]; then
  e_header "Configuring qBittorrent"

  DownloadsSavePath=$(escape "${HOME}/Downloads")
  DownloadsTempPath=$(escape "${HOME}/Downloads/temp")

  e_notify "Enable CloseToTray" \
    $(sed -iq "s/^\\(General\\\CloseToTray=\\).*$/\1true/" "$config")
  e_notify "Set SavePath to $DownloadsSavePath" \
    $(sed -iq "s/^\\(Downloads\\\SavePath=\\).*$/\1$DownloadsSavePath/" "$config")
  e_notify "Enable TempPath" \
    $(sed -iq "s/^\\(Downloads\\\TempPathEnabled=\\).*$/\1true/" "$config")
  e_notify "Set TempPath to $DownloadsTempPath" \
    $(sed -iq "s/^\\(Downloads\\\TempPath=\\).*$/\1$DownloadsTempPath/" "$config")
fi

# }}}
# Gconf {{{

if [ "$(type -P gconftool-2)" ]; then
  e_header "Configuring gconf"

  # Map caps to escape
  # http://askubuntu.com/questions/35890/how-to-programmatically-swap-the-caps-lock-and-esc-keys
  e_notify "Map caps to escape" \
    $(gconftool-2 --set /desktop/gnome/peripherals/keyboard/kbd/options \
      --type list --list-type string \
      '[caps<tab>caps:swapescape]')

  # Workspace keyboard shortcuts
  e_notify "Map move_to_workspace_up to <Primary>XF86Back" \
    $(gconftool-2 --set /apps/metacity/window_keybindings/move_to_workspace_up \
      --type string '<Primary>XF86Back')

  e_notify "Map move_to_workspace_down to <Primary>XF86Forward" \
    $(gconftool-2 --set /apps/metacity/window_keybindings/move_to_workspace_down \
      --type string '<Primary>XF86Forward')

  e_notify "Map switch_to_workspace_up to XF86Back" \
    $(gconftool-2 --set /apps/metacity/global_keybindings/switch_to_workspace_up \
      --type string 'XF86Back')

  e_notify "Map switch_to_workspace_down to XF86Forward" \
    $(gconftool-2 --set /apps/metacity/global_keybindings/switch_to_workspace_down \
      --type string 'XF86Forward')
fi

# }}}
