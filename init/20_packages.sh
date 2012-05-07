# Install APT packages.

# Compilers
packages=(
  gcc g++
  python
  perl
)

# Utilities
packages+=(
  build-essentials libssl-dev
  ubuntu-restricted-extras
  nmap telnet traceroute
  curl
  screen tmux mosh
  ncurses-bin ncruses-base
  zip unzip rar unrar
  lm-sensors lsof htop
  rsync
)

# Lamp-stack
packages+=(
  apache2
  php5 libapache2-mod-5 php-pear php5-cli
  mysql-server
  percona-toolkit
)

# Development tools
packages+=(
  vim
  lftp
  git-core
  optipng
  phpmyadmin
)

# Node.js
packages+=(
  nodejs
  npm
)

# E-mail
packages+=(
  mutt
  offlineimap
  msmtp
)

# Browsers
packages+=(
  google-chrome-beta
  firefox
  opera
)

# Emulators / VM
packages+=(
  wine winetricks
  virtualbox virtualbox-guest-ut virtualbox-guest-x1 virtualbox-guest-dk
)

# GUI stuff
packages+=(
  terminator rxvt-unicode-256color
  thunderbird
  marlin
  gimp
  vlc ffmpeg
  ttf-mscorefonts-ins
  adobeair
  filezilla filezilla-common
  mysql-admin
)

list=()
for package in "${packages[@]}"; do
  if [[ ! "$(dpkg -l "$package" 2>/dev/null | grep "^ii  $package")" ]]; then
    list=("${list[@]}" "$package")
  fi
done

if (( ${#list[@]} > 0 )); then
  e_header "Installing APT packages: ${list[*]}"
  for package in "${list[@]}"; do
    sudo apt-get -qq install "$package"
  done
fi

# Install Npm modules.
if [[ "$(type -P npm)" ]]; then
  echo "Updating Npm" &&
  sudo npm update -g npm

  local modules=(jshint uglify-js stylus compass)

  { pushd "$(npm config get prefix)/lib/node_modules"; installed=(*); popd; } > /dev/null
  list="$(to_install "${modules[*]}" "${installed[*]}")"
  if [[ "$list" ]]; then
    e_header "Installing Npm modules: $list"
    if [[ "$(type -P brew)" ]]; then
      npm install -g $list
    else
      sudo npm install -g $list
    fi
  fi
fi

unset packages package list
