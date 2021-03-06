VERSION="1.2.3"

#set -x

DEBUG=:
DEST_DIR="$HOME"
PRINT=echo
PROMPT=echo_n
ERROR=echo_error
VERBOSE=:
DEFAULT_DOTFILES_DIR="$HOME/.dotfiles"
MKDIR=mkdir
INSTALL=rcup
ROOT_DIR="$HOME"

ln_v() {
  $VERBOSE "'$1' -> '$2'"
  ln -s "$1" "$2"
}

cp_v() {
  $VERBOSE "'$1' -> '$2'"
  cp -R "$1" "$2"
}

rm_v() {
  $VERBOSE "removed '$2'"
  rm $1 "$2"
}

mv_v() {
  $VERBOSE "'$1' -> '$2'"
  mv "$1" "$2"
}

unset CDPATH

echo_n() {
  printf "%s " "$*"
}

echo_error() {
  local exit_status=$1
  shift
  echo "$*" >&2
  exit $exit_status
}

echo_stderr() {
  echo "$*" >&2
}

is_relative() {
  echo "$1" | grep -vq '^/'
}

version() {
  cat << EOV
$1 (rcm) $VERSION
Copyright (C) 2013 Mike Burns
Copyright (C) 2014 thoughtbot
License BSD: BSD 3-clause license

Written by Mike Burns.
EOV
}

handle_common_flags() {
  local prog_name="$1"
  local version="$2"
  local verbosity=$3

  if [ $version -eq 1 ]; then
    version "$prog_name"
    exit 0
  elif [ $verbosity -ge 2 ]; then
    DEBUG=echo_stderr
    VERBOSE=echo
    PRINT=echo
    INSTALL="$INSTALL -vv"
  elif [ $verbosity -eq 1 ]; then
    DEBUG=:
    VERBOSE=echo
    PRINT=echo
    INSTALL="$INSTALL -v"
  elif [ $verbosity -eq 0 ]; then
    DEBUG=:
    VERBOSE=:
    PRINT=echo
  else
    DEBUG=:
    VERBOSE=:
    PRINT=:
    INSTALL="$INSTALL -q"
  fi
}

determine_hostname() {
  local name="$1"

  if [ -n "$name" ]; then
    echo "$name"
  elif [ -n "$HOSTNAME" ]; then
    echo "$HOSTNAME"
  else
    echo "$(hostname | sed -e 's/\..*//')"
  fi
}

run_hooks() {
  $DEBUG "run_hooks $1 $2"
  $DEBUG "  with DOTFILES_DIRS: $DOTFILES_DIRS"
  local when="$1"
  local direction="$2"
  local hook_file
  local find_opts=

  if [ $RUN_HOOKS -eq 1 ]; then
    for dotfiles_dir in $DOTFILES_DIRS; do
      hook_file="$dotfiles_dir/hooks/$when-$direction"

      if [ -e "$hook_file" ]; then
        $VERBOSE "running $when-$direction hooks for $dotfiles_dir"

        if [ x$DEBUG != x: ]; then
          find_opts=-print
        fi

        find "$hook_file" -type f \( \( -user $USER -perm -100 \) -o -perm -001 \) $find_opts -exec {} \;
      else
        $DEBUG "no $when-$direction hook present for $dotfiles_dir, skipping"
      fi
    done
  fi
}

de_dot() {
  $DEBUG "de_dot $1"
  $DEBUG "  with DEST_DIR: $DEST_DIR"
  echo "$1" | sed -e "s|$DEST_DIR/||" | sed -e 's/^\.//'
}

: ${RCRC:=$HOME/.rcrc}

if [ -r "$RCRC" ]; then
  . "$RCRC"
fi
