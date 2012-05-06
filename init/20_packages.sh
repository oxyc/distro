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
  screen tmux
  terminator rxvt-unicode-256color
  ncurses-bin ncruses-base
  zip unzip rar unrar
  lm-sensors lsof
  mosh
  rsync
  htop
)

# Lamp-stack
packages+=(
  apache2
  php5 libapache2-mod-5 php-pear php5-cli
  mysql-server mysql-admin
)

# Development tools
packages+=(
  vim
  lftp
  git-core
  optipng
  phpmyadmin
  filezilla filezilla-common
)

# Browsers
packages+=(
  google-chrome-beta
  firefox
  opera
)

# Node.js
packages+=(
  nodejs
  npm
)

# Emulators / VM
packages+=(
  wine winetricks
  virtualbox virtualbox-guest-ut virtualbox-guest-x1 virtualbox-guest-dk
)

# E-mail
packages+=(
  mutt
  offlineimap
  msmtp
)

# GUI stuff
packages+=(
  thunderbird
  marlin
  gimp
  vlc ffmpeg
  ttf-mscorefonts-ins
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

  modules=(jshint uglify-js stylus compass)

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
