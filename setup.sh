#!/bin/bash
packages=(git base-devel zsh trash-cli curl ttf-mononoki-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono hyfetch oh-my-zsh-git carapace-bin zoxide fzf github-cli bat thefuck)

function swap_shell() {
	if ! (cat /etc/passwd | grep $(whoami) | grep -q zsh); then
		chsh -s /usr/bin/zsh
	fi
}
function paru_get() {
	if ! command -v paru &> /dev/null; then
		git clone https://aur.archlinux.org/paru-bin.git
		cd paru-bin; yes | makepkg -si; cd ..; rm -rf paru-bin
	fi
}
function add_alias() {
	if ! grep -q "$1=$2" ~/.zshrc; then
		echo "alias $1=$2" >> ~/.zshrc
	fi
}
function install() {
	for i in "$@"; do
		if ! paru -Qi "$i" &> /dev/null; then
			yes | paru -S --noconfirm "$i"
		fi
	done
}
function zshrc-add {
	if ! grep -q -F "$1" ~/.zshrc; then 
		echo "$1" >> ~/.zshrc
	fi
}
function zsh-plugins() {
	if [ ! -d ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting ]; then 
		git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
	fi
	if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
		git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	fi
	sed -i "s/plugins=(.*/plugins=(git zoxide zsh-autosuggestions fast-syntax-highlighting thefuck)/" ~/.zshrc
}
function comfyline(){
	if [ ! -f ~/.oh-my-zsh/custom/themes/comfyline.zsh-theme ]; then
		git clone https://gitlab.com/imnotpua/comfyline_prompt
		cd comfyline_prompt; ./install.sh; cd ..; rm -rf comfyline_prompt
	fi
}
function setup() {
	paru_get
	install ${packages[@]}
	comfyline
	zsh-plugins
	zshrc-add "export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'"
	zshrc-add "zstyle ':completion:*' format $'\\e[2;37mCompleting %d\\e[m'"
	zshrc-add "source <(carapace _carapace zsh)"
	zshrc-add "eval \"\$(zoxide init zsh)\""
	zshrc-add "eval \$(thefuck --alias)"
	swap_shell
	add_alias neofetch neowofetch 
}

setup
