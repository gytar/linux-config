#!/usr/bin/env bash

sudo apt -y -qq update && sudo apt -y -qq upgrade

sudo apt -y -qq install zsh flatpak tmux vim
# Install obsidian
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "===== OBSIDIAN ====="
flatpak install flathub md.obsidian.Obsidian
echo "===== END OBSIDIAN ====="

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
cp ./configs/static/.zshrc $HOME/.zshrc
echo "===== END ZSH ====="
echo "===== WEZTERM ====="
sudo apt update
sudo apt install wezterm 
echo "===== END WEZTERM ====="

echo "===== GIT ====="
git config --global user.name "Guillaume Perrot"
git config --global user.email "perrotguillaume@protonmail.com"
git config --gloabl init.defaultBranch main
git config --global rerere.enabled true
git config --global core.editor vim
git config --global merge.tool vimdiff 

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
git clone https://github.com/gytar/nvim-config.git $HOME/.config/nvim 
echo "===== END VIM / NVIM ====="


