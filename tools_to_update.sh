#!/bin/bash

DOTFILEDIR="${HOME}/dotfiles"
DESKTOPBIN="${HOME}/desktop_bin"

# zsh-git-prompt
zsh-git-prompt() {
	git_prompt_dir="$(mktemp -d git_prompt.XXXXXXXXX)"
	git clone "https://github.com/starcraftman/zsh-git-prompt.git" "${git_prompt_dir}"
	cp "${git_prompt_dir}/zshrc.sh" "${DOTFILEDIR}/local/lib/git_prompt/zshrc.sh"
	cp "${git_prompt_dir}/gitstatus.py" "${DOTFILEDIR}/local/lib/git_prompt/gitstatus.py"
	rm -rf "${git_prompt_dir}"
}

# peco
peco() {
	pushd "${GOPATH}/src/github.com/peco/peco" &>/dev/null
	git pull
	#make build
	GO111MODULE=on go build -ldflags="-s -w" cmd/peco/peco.go
	~/go-workspace/bin/goupx peco
	cp peco "${DOTFILEDIR}/local/bin/peco"
	setfattr -n user.pax.flags -v m "${DOTFILEDIR}/local/bin/peco"
	popd &>/dev/null
}

# Technically fasd too, but it hasn't been updated in forever
# https://github.com/clvv/fasd

# Gron
gron() {
	go get github.com/tomnomnom/gron
	pushd "${GOPATH}/src/github.com/tomnomnom/gron" &>/dev/null
	go build -ldflags="-s -w"
	~/go-workspace/bin/goupx gron
	cp gron "${DOTFILEDIR}/local/bin/gron"
	setfattr -n user.pax.flags -v m "${DOTFILEDIR}/local/bin/gron"
	popd &>/dev/null
}

# the_silver_searcher
silver-search() {
	silver_search="$(mktemp -d silver_search.XXXXXXXXX)"
	git clone "https://github.com/ggreer/the_silver_searcher.git" "${silver_search}"
	pushd "${silver_search}" &>/dev/null
	./build.sh
	cp ag "${DOTFILEDIR}/local/bin/ag"
	popd &>/dev/null
	rm -rf "${silver_search}"
}

# ripgrep
ripgrep() {
	rg="$(mktemp -d ripgrep.XXXXXXXXX)"
	git clone "https://github.com/BurntSushi/ripgrep" "${rg}"
	pushd "${rg}" &>/dev/null
	sed -i '/^\[profile.release]$/a opt-level = "z"' Cargo.toml
	sed -i '/^\[profile.release]$/a lto = true' Cargo.toml
	sed -i '/^\[profile.release]$/a codegen-units = 1' Cargo.toml
	PCRE2_SYS_STATIC=1 cargo build --release --features 'pcre2'
	strip target/release/rg
	cp target/release/rg "${DOTFILEDIR}/local/bin/rg"
	popd &>/dev/null
	rm -rf "${rg}"
}

# bfs (breadth first search)
bfs() {
	bfs="$(mktemp -d bfs.XXXXXXXXX)"
	git clone "https://github.com/tavianator/bfs.git" "${bfs}"
	pushd "${bfs}" &>/dev/null
	make
	cp bfs "${DOTFILEDIR}/local/bin/bfs"
	popd &>/dev/null
	rm -rf "${bfs}"
}

# dive (I seem to have a lot of problems building this project from src)
dive() {
	prompt_for_release "https://github.com/wagoodman/dive/releases"
	dive_release="0.9.2"
	dive="$(mktemp -d dive.XXXXXXXXX)"
	pushd "${dive}" &>/dev/null
	wget "https://github.com/wagoodman/dive/releases/download/v${release}/dive_${release}_linux_amd64.tar.gz"
	tar xf "dive_${release}_linux_amd64.tar.gz"
	cp dive "${DESKTOPBIN}/dive"
	popd &>/dev/null
	rm -rf "${dive}"
}

# Reg
reg() {
	go get -v github.com/genuinetools/reg
	cp "${GOPATH}/bin/reg" "${DESKTOPBIN}/reg"
}

# Lab
lab() {
	lab="$(mktemp -d lab.XXXXXXXXX)"
	git clone "https://github.com/zaquestion/lab.git" "${lab}"
	pushd "${lab}" &>/dev/null
	make
	cp lab "${DESKTOPBIN}/lab"
	popd &>/dev/null
	rm -rf "${lab}"
}

# Helm & Tiller
helm() {
	prompt_for_release "https://github.com/helm/helm/releases"
	helm_release="3.2.4"
	wget -O "${HOME}/Downloads/helm.tar.gz" "https://get.helm.sh/helm-v${release}-linux-amd64.tar.gz"
	tar -xC "${DESKTOPBIN}" -f ~/Downloads/helm.tar.gz --strip-components=1 linux-amd64/helm
}

# kubectx
kubectx() {
	prompt_for_release "https://github.com/ahmetb/kubectx/releases"
	#kubectx_release="0.9.4"
	wget -O "${HOME}/Downloads/kubectx.tar.gz" "https://github.com/ahmetb/kubectx/releases/download/v${release}/kubectx_v${release}_linux_x86_64.tar.gz"
	tar -xC "${DESKTOPBIN}" -f ~/Downloads/kubectx.tar.gz kubectx
}

prompt_for_release() {
	printf "Need to find which release to use, go to %s and then return here and enter the version number.\n" "${1}"
	printf "If your version has a 'v' in it, omit the 'v'\n"
	printf "Version Number: "
	read -r release
}

all() {
	zsh-git-prompt
	peco
	gron
	ripgrep
	bfs
	dive
	helm
	kubectx
}

list() {
	echo "zsh-git-prompt, peco, gron, silver-serach, ripgrep, bfs, dive, reg, lab, helm, kubectx"
}

main() {
	case "${1}" in
		zsh-git-prompt|peco|gron|silver-search|ripgrep|bfs|dive|reg|lab|helm|kubectx|list|all)
			${1}
			;;
		*)
			echo "that wasn't a command we recognize"
	esac
}

main "${@}"
