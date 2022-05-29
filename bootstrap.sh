#!/usr/bin/env bash

# For usage with GitHub's codespaces, this should be everything that is needed to setup this dotfiles repo with a
# codespaces virtual environment.

# Global settings
# Set Debug so that we can see what's happening
set -x

# Constants
# This is where vscode puts dotfiles
DOTFILE_LOC=/workspaces/.codespaces/.persistedshare/dotfiles/
# Location for the RCRC script in our dotfiles
export RCRC="${DOTFILE_LOC}/rcrc"

# Install RCM which is used for setting up links to binaries
sudo apt-get install -y rcm tmux

# Change to home directory
pushd "${HOME}" &>/dev/null

# Create dotfiles symlink and bin directory for create_syms and rcup script
ln -sf "${DOTFILE_LOC}" ./dotfiles
mkdir bin

# Run rcup to initialize
rcup -fvvx local

# Call custom create_syms script
"${DOTFILE_LOC}/local/bin/create_syms"

# Install vim plug
mkdir -p ~/.vim/{autoload,plugged}
git clone https://github.com/junegunn/vim-plug.git ~/.vim/plugged/vim-plug
ln -s ~/.vim/plugged/vim-plug/plug.vim ~/.vim/autoload

# Install plugins this appears not to work because when the script is executing its not in an interactive shell
#yes | vim +PlugInstall +qall

# Ensure that /bin/sh is linked to bash instead of dash for git functions
sudo ln -sf /usr/bin/bash /bin/sh

# Go back to where we were
popd &>/dev/null
