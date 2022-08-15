#!/bin/bash

DOTFILEDIR="${HOME}/dotfiles"
DESKTOPBIN="${HOME}/desktop_bin"

# zsh-git-prompt
zsh-git-prompt() {
	local git_prompt_dir
	git_prompt_dir="$(mktemp -d git_prompt.XXXXXXXXX)"
	git clone "https://github.com/starcraftman/zsh-git-prompt.git" "${git_prompt_dir}"
	cp "${git_prompt_dir}/zshrc.sh" "${DOTFILEDIR}/local/lib/git_prompt/zshrc.sh"
	cp "${git_prompt_dir}/gitstatus.py" "${DOTFILEDIR}/local/lib/git_prompt/gitstatus.py"
	rm -rf "${git_prompt_dir}"
}

# peco
peco() {
	pushd "${GOPATH}/src/github.com/peco/peco" &>/dev/null || return
	git pull
	#make build
	GO111MODULE=on go build -ldflags="-s -w" cmd/peco/peco.go
	~/go-workspace/bin/goupx peco
	cp peco "${DOTFILEDIR}/local/bin/peco"
	setfattr -n user.pax.flags -v m "${DOTFILEDIR}/local/bin/peco"
	popd &>/dev/null || return
}

# Technically fasd too, but it hasn't been updated in forever
# https://github.com/clvv/fasd

# Gron
gron() {
	go get github.com/tomnomnom/gron
	pushd "${GOPATH}/src/github.com/tomnomnom/gron" &>/dev/null || return
	go build -ldflags="-s -w"
	~/go-workspace/bin/goupx gron
	cp gron "${DOTFILEDIR}/local/bin/gron"
	setfattr -n user.pax.flags -v m "${DOTFILEDIR}/local/bin/gron"
	popd &>/dev/null || return
}

# the_silver_searcher
silver-search() {
	local silver_search
	silver_search="$(mktemp -d silver_search.XXXXXXXXX)"
	git clone "https://github.com/ggreer/the_silver_searcher.git" "${silver_search}"
	pushd "${silver_search}" &>/dev/null || return
	./build.sh
	cp ag "${DOTFILEDIR}/local/bin/ag"
	popd &>/dev/null || return
	rm -rf "${silver_search}"
}

# ripgrep
ripgrep() {
	local rg
	echo "If this doesn't work, you may have to run the instructions here: https://github.com/BurntSushi/ripgrep#building"
	rg="$(mktemp -d ripgrep.XXXXXXXXX)"
	git clone "https://github.com/BurntSushi/ripgrep" "${rg}"
	pushd "${rg}" &>/dev/null || return
	sed -i '/^\[profile.release]$/a opt-level = "z"' Cargo.toml
	sed -i '/^\[profile.release]$/a lto = true' Cargo.toml
	sed -i '/^\[profile.release]$/a codegen-units = 1' Cargo.toml
	PCRE2_SYS_STATIC=1 cargo build --release --target x86_64-unknown-linux-musl --features 'pcre2'
	strip target/x86_64-unknown-linux-musl/release/rg
	cp target/x86_64-unknown-linux-musl/release/rg "${DOTFILEDIR}/local/bin/rg"
	popd &>/dev/null || return
	rm -rf "${rg}"
}

# bfs (breadth first search)
bfs() {
	local bfs
	bfs="$(mktemp -d bfs.XXXXXXXXX)"
	git clone "https://github.com/tavianator/bfs.git" "${bfs}"
	pushd "${bfs}" &>/dev/null || return
	make
	cp bfs "${DOTFILEDIR}/local/bin/bfs"
	popd &>/dev/null || return
	rm -rf "${bfs}"
}

# dive (I seem to have a lot of problems building this project from src)
dive() {
	local dive
	prompt_for_release "https://github.com/wagoodman/dive/releases"
	#dive_release="0.9.2"
	dive="$(mktemp -d dive.XXXXXXXXX)"
	pushd "${dive}" &>/dev/null || return
	wget "https://github.com/wagoodman/dive/releases/download/v${release}/dive_${release}_linux_amd64.tar.gz"
	tar xf "dive_${release}_linux_amd64.tar.gz"
	cp dive "${DESKTOPBIN}/dive"
	popd &>/dev/null || return
	rm -rf "${dive}"
}

# Reg
reg() {
	go get -v github.com/genuinetools/reg
	cp "${GOPATH}/bin/reg" "${DESKTOPBIN}/reg"
}

# Lab
lab() {
	local lab
	lab="$(mktemp -d lab.XXXXXXXXX)"
	git clone "https://github.com/zaquestion/lab.git" "${lab}"
	pushd "${lab}" &>/dev/null || return
	make
	cp lab "${DESKTOPBIN}/lab"
	popd &>/dev/null || return
	rm -rf "${lab}"
}

# Helm & Tiller
helm() {
	prompt_for_release "https://github.com/helm/helm/releases"
	wget -O "${HOME}/Downloads/helm.tar.gz" "https://get.helm.sh/helm-v${release}-linux-amd64.tar.gz"
	tar -xC "${DESKTOPBIN}" -f ~/Downloads/helm.tar.gz --strip-components=1 linux-amd64/helm
}

kubectl() {
	local kube
	kube="$(mktemp -d kubectl.XXXXXXXXX)"
	pushd "${kube}" &>/dev/null || return
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	chmod 755 kubectl
	cp kubectl "${DESKTOPBIN}/kubectl"
	popd &>/dev/null || return
	rm -rf "${kube}"
}

# kubectx
kubectx() {
	prompt_for_release "https://github.com/ahmetb/kubectx/releases"
	#kubectx_release="0.9.4"
	wget -O "${HOME}/Downloads/kubectx.tar.gz" "https://github.com/ahmetb/kubectx/releases/download/v${release}/kubectx_v${release}_linux_x86_64.tar.gz"
	tar -xC "${DESKTOPBIN}" -f ~/Downloads/kubectx.tar.gz kubectx
}

aws_cli() {
	local aws_cli
	aws_cli="$(mktemp -d aws_cli.XXXXXXXXX)"
	pushd "${aws_cli}" &>/dev/null || return
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	./aws/install -i "${HOME}/.aws-cli" -b "${DESKTOPBIN}"
	popd &>/dev/null || return
	rm -rf "${aws_cli}"
}

hadolint() {
	# Requires: haskell-platform and haskell-stack in order to function
	local hadolint
	hadolint="$(mktemp -d hadolint.XXXXXXXXX)"
	git clone "https://github.com/hadolint/hadolint" "${hadolint}"
	pushd "${hadolint}" &>/dev/null || return
	stack install
	popd &>/dev/null || return
	rm -rf "${hadolint}"
}

rancher() {
	prompt_for_release "https://github.com/rancher/cli/releases"
	wget -O "${HOME}/Downloads/rancher.tar.gz" "https://github.com/rancher/cli/releases/download/v${release}/rancher-linux-amd64-v${release}.tar.xz"
	tar -xC "${DESKTOPBIN}" --strip-components=2 -f ~/Downloads/rancher.tar.gz "./rancher-v${release}/rancher"
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
	aws_cli
	hadolint
	rancher
}

list() {
	echo "zsh-git-prompt, peco, gron, silver-serach, ripgrep, bfs, dive, reg, lab, helm, kubectx, aws_cli, hadolint,"
	echo "rancher"
}

main() {
	case "${1}" in
		zsh-git-prompt|peco|gron|silver-search|ripgrep|bfs|dive|reg|lab|helm|kubectx|kubectl|aws_cli|hadolint|\
			rancher|list|all)
			${1}
			;;
		*)
			echo "that wasn't a command we recognize"
	esac
}

main "${@}"
