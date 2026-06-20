# This script is meant to be sourced.
# It's not for directly running.

function prepare_systemd_user_service(){
  if [[ ! -e "/usr/lib/systemd/user/ydotool.service" ]]; then
    x sudo ln -s /usr/lib/systemd/{system,user}/ydotool.service
  fi
}

function setup_user_group(){
  if [[ -z $(getent group i2c) ]] && [[ "$OS_GROUP_ID" != "fedora" ]]; then
    # On Fedora this is not needed. Tested with desktop computer with NVIDIA video card.
    x sudo groupadd i2c
  fi

  if [[ "$OS_GROUP_ID" == "fedora" ]]; then
    x sudo usermod -aG video,input "$(whoami)"
  else
    x sudo usermod -aG video,i2c,input "$(whoami)"
  fi
}

function setup_clamav(){
  x sudo systemctl enable --now clamav-freshclam clamav-daemon
}

function install_crates(){
  if ! command -v cargo &> /dev/null; then
    echo "cargo command not found"

    if [ -f "$HOME/.cargo/env" ]; then
      echo "Sourcing $HOME/.cargo/env..."
      source "$HOME/.cargo/env"

      if ! command -v cargo &> /dev/null; then
        echo "Error: cargo still not found after sourcing"
        return 1
      fi
    else
      echo "Error: $HOME/.cargo/env not found"
      return 1
    fi
  fi

  x cargo install --locked tree-sitter-cli bacon llmfit elio
}

function setup_bash(){
  BASHRCPATH="$HOME/.bashrc"
  STARSHIP_LINE='eval "$(starship init bash)"'
  NETSTAT_LINE="alias netstat='ss -tunap | grep ESTAB'"

  # Check and add netstat
  grep -qF "$NETSTAT_LINE" "$BASHRCPATH" || echo "$NETSTAT_LINE" >> "$BASHRCPATH"

  # Check and add Starship
  grep -qF "$STARSHIP_LINE" "$BASHRCPATH" || echo "$STARSHIP_LINE" >> "$BASHRCPATH"

  # Check if EDITOR is set
  if [ -z "$EDITOR" ]; then
    echo 'export EDITOR=vim' >> "$HOME/.bashrc"
  fi

  # Check if SYSTEM_LESS is set
  if [ -z "$SYSTEM_LESS" ]; then
    echo 'export SYSTEM_LESS=FRSXM' >> "$HOME/.bashrc"
  fi
}
#####################################################################################
# These python packages are installed using uv into the venv (virtual environment). Once the folder of the venv gets deleted, they are all gone cleanly. So it's considered as setups, not dependencies.
showfun install-python-packages
v install-python-packages

if ! command -v rustc &> /dev/null; then
  showfun install-rust
  v install-rust
  sleep 1
  showfun install_crates
  v install_crates
else
  showfun install_crates
  v install_crates
fi

showfun setup_user_group
v setup_user_group

showfun setup_clamav
v setup_clamav

if [[ ! -z $(systemctl --version) ]]; then
  # For Fedora, uinput is required for the virtual keyboard to function, and udev rules enable input group users to utilize it.
  if [[ "$OS_GROUP_ID" == "fedora" ]]; then
    v bash -c "echo uinput | sudo tee /etc/modules-load.d/uinput.conf"
    v bash -c 'echo SUBSYSTEM==\"misc\", KERNEL==\"uinput\", MODE=\"0660\", GROUP=\"input\" | sudo tee /etc/udev/rules.d/99-uinput.rules'
  else
    v bash -c "echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf"
  fi
  # TODO: find a proper way for enable Nix installed ydotool. When running `systemctl --user enable ydotool, it errors "Failed to enable unit: Unit ydotool.service does not exist".
  if [[ ! "${INSTALL_VIA_NIX}" == true ]]; then
    if [[ "$OS_GROUP_ID" == "fedora" ]]; then
      v prepare_systemd_user_service
    fi
    # When $DBUS_SESSION_BUS_ADDRESS and $XDG_RUNTIME_DIR are empty, it commonly means that the current user has been logged in with `su - user` or `ssh user@hostname`. In such case `systemctl --user enable <service>` is not usable. It should be `sudo systemctl --machine=$(whoami)@.host --user enable <service>` instead.
    if [[ ! -z "${DBUS_SESSION_BUS_ADDRESS}" ]]; then
      v systemctl --user enable ydotool --now
    else
      v sudo systemctl --machine=$(whoami)@.host --user enable ydotool --now
    fi
  fi
  v sudo systemctl enable bluetooth --now
elif [[ ! -z $(openrc --version) ]]; then
  v bash -c "echo 'modules=i2c-dev' | sudo tee -a /etc/conf.d/modules"
  v sudo rc-update add modules boot
  v sudo rc-update add ydotool default
  v sudo rc-update add bluetooth default

  x sudo rc-service ydotool start
  x sudo rc-service bluetooth start
else
  printf "${STY_RED}"
  printf "====================INIT SYSTEM NOT FOUND====================\n"
  printf "${STY_RST}"
  pause
fi

if [[ "$OS_GROUP_ID" == "gentoo" ]]; then
  v sudo chown -R $(whoami):$(whoami) ~/.local/
fi

showfun setup_bash
v setup_bash

v gsettings set org.gnome.desktop.interface font-name 'Google Sans Flex Medium 11 @opsz=11,wght=500'
v gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
v kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Darkly

v chsh -s /usr/bin/fish
