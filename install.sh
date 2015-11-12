#!/bin/bash


set -e
function error () {
    echo $*
    exit 1
}

function usage () {
    echo "usage: $0 [-l] [-f] bindir";
    exit 0
}
function help () {
cat <<EOF
Install files from src/ to the specified directory.
Install files from dot/ to the home directory, with "." prepended.

OPTIONS

  -f  Force: Overwrite existing targets. Default is not to.
  -l  Links: Use symbolic links instead of making copies.
  -n  Not-really: Show what would be done without doing it.
EOF
}

notreally=
links=
force=
function doit () {
    echo "$*"
    if [ $notreally ]; then return; fi
    eval $* || error "Failed."
}

function tryit() {
    echo "$*"
    if [ $notreally ]; then return; fi
    eval $* || echo "WARNING: Failed. Continuing..." && return -1;
    return 0;
}
ARGS=
function parseopts () {
    while true ; do
        case "$1" in
            '')
                break
                ;;
            -h | --help)
                help
                exit 0
                ;;
            -n | --notreally)
		            notreally=1
		            shift
		            ;;
            -f | --force)
                force=1
                shift
                ;;
            -l | --links)
                links=1
                shift
                ;;
	          *)
		            ARGS="$ARGS $1"
		            shift
		            ;;
	      esac
    done
}

parseopts $@
function install_to_bin() {
    bindir=$1
    if [ -z "$bindir" ]; then
        bindir="$HOME/bin"
    fi
    install_cmd=/bin/cp
    if [ -n "$links" ]; then
        install_cmd="/bin/ln -s"
    fi
    if [ -n "$force" ]; then
        install_cmd="$install_cmd -f"
    fi
    for executable in src/*; do
        name=`basename $executable`
        doit $install_cmd $executable $bindir/$name
        chmod +x $bindir/$basename
    done
    for dotfile in dot/*; do
        name=`basename $dotfile`
        doit $install_cmd $dotfile $HOME/.$name
    done
}

install_to_bin $ARGS
