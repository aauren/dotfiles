#!/bin/bash

DOTFILEDIR="${HOME}/dotfiles"
DESKTOPBIN="${HOME}/desktop_bin"

# zsh-git-prompt
git_prompt_dir="$(mktemp -d git_prompt.XXXXXXXXX)"
git clone "https://github.com/starcraftman/zsh-git-prompt.git" "${git_prompt_dir}"
cp "${git_prompt_dir}/zshrc.sh" "${DOTFILEDIR}/local/lib/git_prompt/zshrc.sh"
cp "${git_prompt_dir}/gitstatus.py" "${DOTFILEDIR}/local/lib/git_prompt/gitstatus.py"
rm -rf "${git_prompt_dir}"

# peco
pushd "${GOPATH}/src/github.com/peco/peco" &>/dev/null
git pull
#make build
GO111MODULE=on go build -ldflags="-s -w" cmd/peco/peco.go
~/go-workspace/bin/goupx peco
cp peco "${DOTFILEDIR}/local/bin/peco"
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

# dive (I seem to have a lot of problems building this project from src)
# Go here and find the latest release: https://github.com/wagoodman/dive/releases
dive_release="0.7.2"
dive="$(mktemp -d dive.XXXXXXXXX)"
pushd "${dive}" &>/dev/null
wget "https://github.com/wagoodman/dive/releases/download/v${dive_release}/dive_${dive_release}_linux_amd64.tar.gz"
tar xf "dive_${dive_release}_linux_amd64.tar.gz"
cp dive "${DESKTOPBIN}/dive"
popd &>/dev/null
rm -rf "${dive}"

# Reg
go get -v github.com/genuinetools/reg
cp "${GOPATH}/bin/reg" "${DESKTOPBIN}/reg"

# Lab
lab="$(mktemp -d lab.XXXXXXXXX)"
git clone "https://github.com/zaquestion/lab.git" "${lab}"
pushd "${lab}" &>/dev/null
make
cp lab "${DESKTOPBIN}/lab"
popd &>/dev/null
rm -rf "${lab}"

# Helm & Tiller
# Go here and find the latest release: https://github.com/helm/helm/releases
helm_release="2.14.1"
wget -O "${HOME}/Downloads/helm.tar.gz" "https://get.helm.sh/helm-v${helm_release}-linux-amd64.tar.gz"
tar -xC "${DESKTOPBIN}" -f ~/Downloads/helm.tar.gz --strip-components=1 linux-amd64/helm
tar -xC "${DESKTOPBIN}" -f ~/Downloads/helm.tar.gz --strip-components=1 linux-amd64/tiller
