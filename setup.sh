#!/bin/bash
function command_exists() {
	which "$1" >/dev/null 2>&1
}
function check_install() {
	#Checks whether package is installed locally using pacman
	if pacman -Qi "$1" &> /dev/null; then
		echo "Package $1 is already installed..."
 	else
    		echo "Installing $1..."
    		yes | sudo pacman -S "$1"
  	fi
}
function set_omz_update_option() {
	#Takes two arguments, the update option to be changed, and the value it is to be changed to
	#Then adds it to ~/.zshrc if the option is not already set to the value in it
	option="$1"
 	value="$2"
  	if grep -q ^"zstyle ':omz:update' $option $value" ~/.zshrc; then
    		echo "Update $option already set to $value..."
  	else
    		echo "Setting update $option to $value..."
    		sed -i "/^zstyle ':omz:update' $option/d" ~/.zshrc 
    		echo "zstyle ':omz:update' $option $value" >> ~/.zshrc
  	fi
}
function add_alias() {
	#Takes two arguments, the name of the alias, and what the alias does
	#Then adds to ~/.zshrc if the aliases are not already there
	a_name="$1"
	a_val="$2"
	if grep -q "$a_name=$a_val" ~/.zshrc ; then 
		echo "$a_name alias already set"
	else
		echo "Setting $a_name alias..."
		echo "alias $a_name=$a_val" >> ~/.zshrc
	fi
}







function setup_paru() {
	echo -e "\nSetting up paru..."
	#Checks whether the paru command exists
	if ! command_exists paru ; then
		echo "Installing paru..."
		git clone --progress https://aur.archlinux.org/paru-bin.git
		cd paru-bin
		makepkg -si
		cd ..
		rm -rf paru-bin
		echo "Paru finished installing..."
	else 
		echo "Paru already installed..."
	fi
}
function setup_zsh() {
	echo -e "\nSetting up zsh..."

	#Ensures the .zshrc file exists
	if [ ! -f ~/.zshrc ]; then
        	echo "~/.zshrc not found, creating now..."
		touch ~/.zshrc
    	fi

	#Installs oh-my-zsh	
	if [ ! -d ~/.oh-my-zsh ]; then
 		echo "Installing oh-my-zsh..."
 		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 
		echo "oh-my-zsh finished installing..."
	else
		echo "oh-my-zsh already installed..."
	fi

	#Installs comfyline prompt
	if [ ! -f ~/.oh-my-zsh/custom/themes/comfyline.zsh-theme ]; then
  		echo "Installing comfyline prompt..."
 		git clone https://gitlab.com/imnotpua/comfyline_prompt
  		cd comfyline_prompt
  		./install.sh
  		cd ..
  		rm -rf comfyline_prompt
	else
		echo "Comfyline prompt already installed..."
	fi

	set_omz_update_option mode auto
	set_omz_update_option frequency 7
}

echo -e "\nInstalling packages..."

check_install git 
check_install base-devel
check_install zsh
check_install trash-cli
check_install curl
check_install ttf-mononoki-nerd
check_install ttf-nerd-fonts-symbols
check_install ttf-nerd-fonts-symbols-mono

echo -e "\nSetting up aliases..."
	
add_alias pacrubbish "'pacman -Qdtq | sudo pacman -Rns -'"
add_alias pacrem "'pacman -R'"
add_alias pacin "'sudo pacman -Sy'"

setup_paru
setup_zsh

