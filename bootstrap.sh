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
sudo apt install rcm

# Change to home directory
pushd "${HOME}" &>/dev/null

# Run rcup to initialize
rcup -fvvx local

# Create dotfiles symlink and bin directory for create_syms script
ln -sf "${DOTFILE_LOC}" ./dotfiles
mkdir bin
"${DOTFILE_LOC}/local/bin/create_syms"

# Install vim plug
mkdir -p ~/.vim/{autoload,plugged}
git clone https://github.com/junegunn/vim-plug.git ~/.vim/plugged/vim-plug
ln -s ~/.vim/plugged/vim-plug/plug.vim ~/.vim/autoload

# Install plugins
yes | vim +PlugInstall +qall

# Go back to where we were
popd &>/dev/null
