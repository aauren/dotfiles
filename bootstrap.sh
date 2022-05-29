#!/usr/bin/env bash

# For usage with GitHub's codespaces, this should be everything that is needed to setup this dotfiles repo with a
# codespaces virtual environment.

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
rcup -fx local

# Create dotfiles symlink and bin directory for create_syms script
ln -sf "${DOTFILE_LOC}" ./dotfiles
mkdir bin
"${DOTFILE_LOC}/local/bin/create_syms"

# Go back to where we were
popd &>/dev/null
