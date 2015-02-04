# This script creates the symlinks necessary to actually use the local files
# contained in the parent directory.

if [[ -d ${HOME}/dotfiles ]]; then
  for DOT_FILE in $(ls -A "${HOME}"/dotfiles/local/ln); do
    echo "linking ${DOT_FILE}"
    ln -sf "${HOME}"/dotfiles/local/ln/"${DOT_FILE}" "${HOME}"/."${DOT_FILE}"
  done
fi

echo "linking ssh configurations"
[[ -d ${HOME}/.ssh/config.d ]] || mkdir ${HOME}/.ssh/config.d
ln -sf "${HOME}"/dotfiles/local/ssh_config "${HOME}"/.ssh/config.d/config.general

echo "linking bin files"
if [[ -d ${HOME}/bin ]]; then
  ln -sf "${HOME}"/dotfiles/local/bin/* ${HOME}/bin
fi
