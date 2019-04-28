#!/usr/bin/env bash

# https://github.com/tuxcfg/backup

# exit immediately if a command exits with a non-zero status
set -e

HELP="Usage: backup [OPTIONS]
\n
\nOptions:
\n -s, --source \t directory or directory list to backup
\n -t, --target \t destination root directory
\n -n, --name   \t directory in target
\n --debug      \t show additional debug info
\n --help       \t show this help
"

# base defaults
SOURCE=""
TARGET="backup"
NAME="data/`date +"%Y.%m.%d"`"
DEBUG=0

# get CLI options
for argument in "$@"; do
    case $argument in
        -s=*|--source=*)
            SOURCE="${argument#*=}"
            shift
            ;;

        -t=*|--target=*)
            TARGET="${argument#*=}"
            shift
            ;;

        -n=*|--name=*)
            NAME="${argument#*=}"
            shift
            ;;

        --debug)
            DEBUG=1
            shift
            ;;

        --help)
            echo -e $HELP
            exit
            ;;

        *)
            echo "Unknown option!"
            exit 1
            ;;
    esac
done

# check user input for --source
if [ -z "$SOURCE" ]; then
    echo "Source can not be empty!"
    exit 1
fi

# check user input for --target
if [ -z "$TARGET" ]; then
    echo "Target can not be empty!"
    exit 1
fi

# convert to lowercase
NAME=${NAME,,}

# main storage dirs
PATH_HEAD="$TARGET/.head"
PATH_DATA="$TARGET/$NAME"

((DEBUG)) \
    && echo "SOURCE: $SOURCE" \
    && echo "TARGET: $PATH_HEAD $PATH_DATA"

# make sure all directories are present
mkdir -p "$PATH_HEAD" "$PATH_DATA"

# make absolute paths
PATH_HEAD="`realpath "$PATH_HEAD"`"
PATH_DATA="`realpath "$PATH_DATA"`"

# update head
rsync \
    --acls \
    --archive \
    --delete \
    --log-file="$PATH_HEAD.log" \
    --xattrs \
    $SOURCE "$PATH_HEAD"

# name can be empty - no hardlinks then
if [ ! -z "$NAME" ]; then
    # create/update hardlinks
    rsync \
        --acls \
        --archive \
        --delete \
        --link-dest="$PATH_HEAD" \
        --log-file="$PATH_DATA.log" \
        --xattrs \
        "$PATH_HEAD/" "$PATH_DATA"
fi
