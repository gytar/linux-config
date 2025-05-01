#!/usr/bin/env bash

sudo apt -y -qq update && sudo apt -y -qq upgrade

sudo apt -y -qq install zsh flatpak tmux vim fzf nodejs npm
# Install obsidian
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# after reboot. 
echo "===== FLATPAKS ====="
# flatpak install flathub org.gimp.GIMP
echo "===== END FLATPAKS ====="

# Install codeium
echo "===== CODIUM ======"
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | sudo apt-key add -
echo 'deb https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/repos/debs/ vscodium main' | sudo tee --append /etc/apt/sources.list.d/vscodium.list
sudo apt -y -qq update
sudo apt -y -qq install codium

while read extension;  do
    codium --install-extension "${extension}"
done < ./configs/vscode-extension-list.txt
echo "===== END CODIUM ====="

echo "===== ZSH ====="
echo "Change shell"
sudo chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
cp ./configs/static/.zshrc $HOME/.zshrc

sudo npm install --global pure-prompt

# install nerd font
wget -O - https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip > CascadiaCode.zip
unzip CascadiaCode.zip 
mkdir -p $HOME/.local/share/fonts
mv CascadiaCode/* $HOME/.local/share/fonts
echo "===== END ZSH ====="

echo "===== WEZTERM ====="
sudo apt -y -qq update
sudo apt -y -qq install wezterm 
cp ./configs/static/.wezterm.lua $HOME/.wezterm.lua
gsettings set org.gnome.desktop.default-applications.terminal exec wezterm
echo "===== END WEZTERM ====="

echo "===== GIT ====="
git config --global user.name "Guillaume Perrot"
git config --global user.email "perrotguillaume@protonmail.com"
git config --gloabl init.defaultBranch main
git config --global rerere.enabled true
git config --global core.editor vim
git config --global merge.tool vimdiff 

ssh-keygen -t ed25519 -C "perrotguillaume@protonmail.com"


# Install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
echo "===== END GIT====="

echo "===== VIM / NVIM ====="
# VIM and NVIM
# Copy .vimrc
cp ./configs/static/.vimrc $HOME/.vimrc

# Install nvim appimage globally
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
./squashfs-root/AppRun --version
mv squashfs-root /
ln -s /squashfs-root/AppRun /usr/bin/nvim
# Install personnal configuration
git clone --filter=blob:none --depth 1 --single-branch -b main https://github.com/gytar/nvim-config.git $HOME/.config/nvim 
echo "===== END VIM / NVIM ====="

echo "===== DevOps tools ====="

echo "===== DOCKER ====="
sudo apt -y -qq install podman
# docker
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
# Add Docker's official GPG key:
sudo apt-get -y -qq update
sudo apt-get -y -qq install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y -qq update
sudo apt-get -y -qq install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

echo "===== END DOCKER ====="

echo "===== OPEN TOFU ====="
# Download the installer script:
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
# Alternatively: wget --secure-protocol=TLSv1_2 --https-only https://get.opentofu.org/install-opentofu.sh -O install-opentofu.sh

# Give it execution permissions:
chmod +x install-opentofu.sh

# Please inspect the downloaded script

# Run the installer:
./install-opentofu.sh --install-method deb

# Remove the installer:
rm -f install-opentofu.sh

echo "===== virtualization ======"
sudo apt install qemu-system libvirt-daemon-system
sudo adduser $USER libvirt 

# python3 -m pip install --user ansible

