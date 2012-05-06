#/bin/bash

qbt_conf="$HOME/.config/qBittorrent/qBittorrent.conf"
vlc_conf="$HOME/.config/vlc/vlcrc"
mimeinfo_conf="/usr/share/applications/mimeinfo.cache"
defaults_conf="/usr/share/applications/defaults.list"

# Crontab {{{

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
unset jobs

# }}}
# VLC {{{

if [ -e "$config" ]; then
  e_header "Configuring VLC"

  e_notify "Enable Minimal View" \
    $(sed -iq 's/^\(qt-minimal-view=\).*$/\11/' "$vlc_conf")
  e_notify "Disable Privacy Ask" \
    $(sed -iq 's/^\(qt-privacy-ask=\).*$/\10/' "$vlc_conf")
  e_notify "Set Volume to 400%" \
    $(sed -iq 's/^\(volume=\).*$/\1400/' "$vlc_conf")

  e_notify "Replace all totem usage with vlc" \
    $(sudo sed -iq 's/totem\.desktop/vlc\.desktop/g' "$mimeinfo_conf" \
      && sudo sed -iq 's/totem\.desktop/vlc\.desktop/g' "$defaults_conf")
fi

# }}}
# qBittorrent {{{


if [ -e "$config" ]; then
  e_header "Configuring qBittorrent"

  local DownloadsSavePath=$(escape "${HOME}/Downloads")
  local DownloadsTempPath=$(escape "${HOME}/Downloads/temp")

  e_notify "Enable CloseToTray" \
    $(sed -iq "s/^\\(General\\\CloseToTray=\\).*$/\1true/" "$qbt_conf")
  e_notify "Set SavePath to $DownloadsSavePath" \
    $(sed -iq "s/^\\(Downloads\\\SavePath=\\).*$/\1$DownloadsSavePath/" "$qbt_conf")
  e_notify "Enable TempPath" \
    $(sed -iq "s/^\\(Downloads\\\TempPathEnabled=\\).*$/\1true/" "$qbt_conf")
  e_notify "Set TempPath to $DownloadsTempPath" \
    $(sed -iq "s/^\\(Downloads\\\TempPath=\\).*$/\1$DownloadsTempPath/" "$qbt_conf")
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

  if [ "$(type -P google-chrome)" ]; then
    e_notify "Use chrome as default browser" \
      $(gconftool-2 --set /desktop/gnome/applications/browser/exec \
          --type string $(which google-chrome))
  fi

  if [ "$(type -P marlin)" ]; then
    e_notify "Use marlin as default file browser" \
      $(gconftool-2 --set /desktop/gnome/applications/component_viewer/exec \
          --type string 'marlin %s')
  fi

  if [ "$(type -P urxvt)" ]; then
    e_notify "Use urxvt as default terminal" \
      $(gconftool-2 --set /desktop/gnome/applications/terminal/exec \
          --type string 'urxvt' \
        && gconftool-2 --set /desktop/gnome/applications/terminal/exec_arg \
        --type string '-e')
  fi
fi

# }}}

unset qbt_conf vlc_conf mimeinfo_conf defaults_conf
