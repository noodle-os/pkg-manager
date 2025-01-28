#!/bin/sh

PKG_DB="https://raw.githubusercontent.com/noodle-os/packages/refs/heads/main/package-db.noodle"
INSTALLED_DB="/var/lib/noodle/installed.noodle"
INSTALL_DIR="/bin/"
LOG_FILE="/var/log/noodle.log"

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as sudo."
  exit 1
fi

init_noodle() {
  if [ ! -f "$INSTALLED_DB" ]; then
    mkdir -p "$(dirname "$INSTALLED_DB")"
    touch "$INSTALLED_DB"
  fi
  if [ ! -f "$LOG_FILE" ]; then
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"
  fi
}

log_message() {
  echo "$(date): $1" | tee -a "$LOG_FILE" > /dev/null
}

is_installed() {
  grep -q "^$1|" "$INSTALLED_DB"
}

install_package() {
  pkg_name=$1

  echo "Fetching package database..."
  log_message "Fetching package database..."
  pkg_info=$(wget -qO- --no-cache  "$PKG_DB" | grep "^$pkg_name|") 

  if [ -z "$pkg_info" ]; then
    echo "Error: Package '$pkg_name' not found in the database."
    log_message "Error: Package '$pkg_name' not found in the database."
    exit 1
  fi

  ver=$(echo "$pkg_info" | cut -d'|' -f2)
  pkg_url=$(echo "$pkg_info" | cut -d'|' -f3)

  if is_installed "$pkg_name"; then
    installed_ver=$(grep "^$pkg_name|" "$INSTALLED_DB" | cut -d'|' -f2)
    if [ "$ver" = "$installed_ver" ]; then
      echo "Package '$pkg_name' is already installed (version $ver)."
      log_message "Package '$pkg_name' is already installed (version $ver)."
      exit 0
    else
      echo "Upgrading '$pkg_name' from version $installed_ver to $ver..."
      log_message "Upgrading '$pkg_name' from version $installed_ver to $ver..."
    fi
  else
    echo "Installing '$pkg_name' version $ver..."
    log_message "Installing '$pkg_name' version $ver..."
  fi

  pkg_file="/tmp/${pkg_name}-v${ver}.tar.gz"

  echo "Downloading $pkg_name..."
  log_message "Downloading $pkg_name from $pkg_url..."
  if ! wget -q "$pkg_url" -O "$pkg_file"; then
    echo "Error: Failed to download $pkg_name from $pkg_url."
    log_message "Error: Failed to download $pkg_name from $pkg_url."
    exit 1
  fi

  echo "Extracting package..."
  log_message "Extracting package..."
  if ! tar -xzf "$pkg_file" -C /tmp/; then
      echo "Error: Failed to extract $pkg_file."
      log_message "Error: Failed to extract $pkg_file."
      rm -f "$pkg_file"
      exit 1
  fi

  if [ -d "/tmp/$pkg_name" ] && [ -f "/tmp/$pkg_name/$pkg_name" ]; then
      if ! mv "/tmp/$pkg_name/$pkg_name" "$INSTALL_DIR"; then
          echo "Error: Failed to move files to $INSTALL_DIR."
          log_message "Error: Failed to move files to $INSTALL_DIR."
          rm -rf "/tmp/$pkg_name"
          exit 1
      fi
  else
      echo "Error: Package files not found in /tmp/$pkg_name."
      log_message "Error: Package files not found in /tmp/$pkg_name."
      exit 1
  fi

  echo "$pkg_name|$ver" | tee -a "$INSTALLED_DB" > /dev/null
  log_message "Package '$pkg_name' version $ver installed successfully."

  rm -f "$pkg_file"
  echo "Package '$pkg_name' version $ver installed successfully."
}

remove_package() {
  pkg_name=$1

  if ! is_installed "$pkg_name"; then
    echo "Error: Package '$pkg_name' is not installed."
    log_message "Error: Package '$pkg_name' is not installed."
    exit 1
  fi

  echo "Removing package '$pkg_name'..."
  log_message "Removing package '$pkg_name'..."
  if ! rm -rf "$INSTALL_DIR/$pkg_name"; then
    echo "Error: Failed to remove package files."
    log_message "Error: Failed to remove package files."
    exit 1
  fi

  sed -i "/^$pkg_name|/d" "$INSTALLED_DB"
  log_message "Package '$pkg_name' removed successfully."

  echo "Package '$pkg_name' removed successfully."
}

list_installed() {
  if [ ! -s "$INSTALLED_DB" ]; then
    echo "No packages installed."
    log_message "No packages installed."
    return
  fi

  echo "Installed packages:"
  log_message "Listing installed packages..."
  cat "$INSTALLED_DB" | awk -F'|' '{printf "- %s (version %s)\n", $1, $2}'
}

info_package() {
  pkg_name=$1

  pkg_info=$(wget -qO- "$PKG_DB" | grep "^$pkg_name|")

  if [ -z "$pkg_info" ]; then
    echo "Error: Package '$pkg_name' not found in the database."
    log_message "Error: Package '$pkg_name' not found in the database."
    exit 1
  fi

  ver=$(echo "$pkg_info" | cut -d'|' -f2)
  url=$(echo "$pkg_info" | cut -d'|' -f3)

  echo "Package: $pkg_name"
  echo "Version: $ver"
  echo "URL: $url"
  log_message "Displayed information for package '$pkg_name'."
}

display_help() {
  echo "Usage: noodle <command> [arguments]"
  echo ""
  echo "Commands:"
  echo "  install <package>   Install a package"
  echo "  remove <package>    Remove a package"
  echo "  list                List all installed packages"
  echo "  info <package>      Show information about a package"
  log_message "Displayed help information."
}

init_noodle

if [ $# -lt 1 ]; then
  display_help
  exit 1
fi

command=$1
pkg_name=$2

case $command in
  install)
    [ -z "$pkg_name" ] && { echo "Error: Missing package name."; log_message "Error: Missing package name."; exit 1; }
    install_package "$pkg_name"
    ;;
  remove)
    [ -z "$pkg_name" ] && { echo "Error: Missing package name."; log_message "Error: Missing package name."; exit 1; }
    remove_package "$pkg_name"
    ;;
  list)
    list_installed
    ;;
  info)
    [ -z "$pkg_name" ] && { echo "Error: Missing package name."; log_message "Error: Missing package name."; exit 1; }
    info_package "$pkg_name"
    ;;
  *)
    echo "Error: Invalid command '$command'."
    log_message "Error: Invalid command '$command'."
    display_help
    exit 1
    ;;
esac
