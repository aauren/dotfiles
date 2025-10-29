if command -v nvim &>/dev/null; then
	export VISUAL=nvim
else
	export VISUAL=vim
fi
export EDITOR=$VISUAL
