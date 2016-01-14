#!/bin/bash
# This script creates the symlinks necessary to actually use the local files
# contained in the parent directory.

# if the dotfiles directory doesn't exist then there is really no reason to continue any of this
[[ -d ${HOME}/dotfiles ]] || exit 1

for DOT_FILE in "${HOME}/dotfiles/local/ln/"*; do
	if [[ ! -d "${HOME}/.${DOT_FILE}" ]]; then
		echo "linking ${DOT_FILE}"
		ln -sf "${DOT_FILE}" "${HOME}/.$(basename DOT_FILE)"
	fi
done

echo "linking ssh configurations"
[[ -d ${HOME}/.ssh/config.d ]] || mkdir "${HOME}/.ssh/config.d"
ln -sf "${HOME}/dotfiles/local/ssh_config" "${HOME}/.ssh/config.d/config.general"

echo "linking bin files"
if [[ -d ${HOME}/bin ]]; then
  ln -sf "${HOME}"/dotfiles/local/bin/* "${HOME}"/bin
fi

echo "linking config files"
[[ -d ${HOME}/.config ]] || mkdir .config
ln -sf "${HOME}"/dotfiles/local/config/* "${HOME}"/.config
