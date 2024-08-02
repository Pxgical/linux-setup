#!/bin/bash

function check_install() {
	#Checks whether package is installed locally using pacman
	if pacman -Qi "$1" &> /dev/null; then
		echo "Package $1 is already installed..."
 	else
    		echo "Installing $1..."
    		sudo pacman -S "$1"
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
    		sed -i "s/^zstyle ':omz:update' $option/d" ~/.zshrc 
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
	echo -e "\nStarting paru setup..."
	#Checks whetehr the paru command exists
	if ! command -v paru &> /dev/null; then
		echo "Installing paru..."
		check_install git
		git clone --progress https://aur.archlinux.org/paru-bin.git
		cd paru-bin
		makepkg -si paru-bin
		cd ..
		rm -rf paru-bin
	else 
		echo "Paru already installed..."
	fi
}
function setup_aliases() {
	echo -e "\nStarting alias setup..."
	
	#Adds an alias to clean up unneeded packages
	add_alias pacrubbish "'pacman -Qdtq | sudo pacman -Rns -'"
}
function setup_zsh() {
	echo -e "\nStarting zsh setup..."
	check_install zsh

	#Ensures the .zshrc file exists
	if [ ! -f ~/.zshrc ]; then
        	echo "Zshrc not found, creating now..."
		touch ~/.zshrc
    	fi

	#Installs oh-my-zsh	
	if [ ! -d ~/.oh-my-zsh ]; then
 		echo "Installing oh-my-zsh..."
 		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 
	else
		echo "oh-my-zsh already installed..."
	fi

	#Installs comfyline prompt
	if [ ! -f ~/.oh-my-zsh/custom/themes/comfyline.zsh-theme ]; then
		check_install git
  		echo "Installing comfyline theme..."
 		git clone https://gitlab.com/imnotpua/comfyline_prompt
  		cd comfyline_prompt
  		./install.sh
  		cd ..
  		rm -rf comfyline_prompt
	else
		echo "Comfyline already installed..."
	fi

	#Sets oh-my-zsh's update mode to automatic
	set_omz_update_option mode auto
	#Sets oh-my-zsh's update frequency to weekly
	set_omz_update_option frequency 7
}

setup_paru
setup_zsh
setup_aliases
