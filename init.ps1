# Init script for worskstation

# Powershell on Linux
if ($IsLinux) {
  # ensure tooling
  sudo apt update -y
  sudo apt install wget -y
  sudo apt autoremove -y

  # run init
  sh -c "wget -qO- https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh"
}

# Powershell on Windows
if ($IsWindows) {
  wsl --install -d ubuntu

  # run the init.sh in wsl
}
