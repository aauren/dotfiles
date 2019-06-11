#!/bin/bash

DOTFILEDIR="${HOME}/dotfiles"

# zsh-git-prompt
git_prompt_dir="$(mktemp -d git_prompt.XXXXXXXXX)"
git clone "https://github.com/starcraftman/zsh-git-prompt.git" "${git_prompt_dir}"
cp "${git_prompt_dir}/zshrc.sh" "${DOTFILEDIR}/local/lib/git_prompt/zshrc.sh"
cp "${git_prompt_dir}/gitstatus.py" "${DOTFILEDIR}/local/lib/git_prompt/gitstatus.py"
rm -rf "${git_prompt_dir}"

# peco
pushd "${GOPATH}/src/github.com/peco/peco" &>/dev/null
git pull
make build
cp releases/peco_linux_amd64/peco "${DOTFILEDIR}/local/bin/peco"
popd &>/dev/null

# Technically fasd too, but it hasn't been updated in forever
# https://github.com/clvv/fasd

# Gron
go get -vu github.com/tomnomnom/gron
cp "${GOPATH}/bin/gron" "${DOTFILEDIR}/local/bin/gron"

# the_silver_searcher
silver_search="$(mktemp -d silver_search.XXXXXXXXX)"
git clone "https://github.com/ggreer/the_silver_searcher.git" "${silver_search}"
pushd "${silver_search}" &>/dev/null
./build.sh
cp ag "${DOTFILEDIR}/local/bin/ag"
popd &>/dev/null
rm -rf "${silver_search}"

# bfs (breadth first search)
bfs="$(mktemp -d bfs.XXXXXXXXX)"
git clone "https://github.com/tavianator/bfs.git" "${bfs}"
pushd "${bfs}" &>/dev/null
make
cp bfs "${DOTFILEDIR}/local/bin/bfs"
popd &>/dev/null
rm -rf "${bfs}"
