#!/usr/bin/env bash

# 
# Tool for building self-contained installers.
# Copyright (C) 2018 by Harald Lapp <harald@octris.org>
#

version="0.0.1"
custom=""
verbose=true
tempfiles=()

function showusage {
    echo "usage: $(basename $0) [OPTIONS] [--] <source> <target>
    
Creates a self-contained installer from the specified source and stores it to
the specified target.

ARGUMENTS

    <source>    Expects a file-name, a directory name or '-' for stdin. If the
                name of a directory is specified, the tool will create a tar 
                archive from it. If the source is no directory an additional
                custom installer script needs to be added using the options
                '-s' or '--script'.

    <target>    Either a file-name or '-' for stdout.

OPTIONS

-q, --quiet     Omit error and status messages.
-s, --script    Additional custom installer script. This argument is required
                if the source is either a file or stdin. This argument is 
                discarded if the source is a directory.
-h, --help      Display this usage information.
    --version   Show version and exit.
"
}

function log {
    if [[ $verbose = true ]]; then
        echo "$@" 1>&2
    fi
}

function addtemp {
    tempfiles="$tempfiles $1"
}

function cleanup {
    local $tempfile
    
    for tempfile in $tempfiles; do
        rm "$tempfile";
    done
}

trap 'cleanup' EXIT HUP INT QUIT TERM

while [[ "${1:0:1}" = "-" ]]; do
    case $1 in
        -)
            break
            ;;
        --)
            shift
            break
            ;;
        -q|--quiet)
            verbose=false
            ;;
        -s|--script)
            custom="$2"
            shift
            ;;
        -h|-\?|--help)
            showusage
            exit 1
            ;;
        --version)
            echo $version
            exit 1
            ;;
    esac
    
    shift
done

if [ "$2" = "" ]; then
    showusage
    exit 1
fi

if [ "$2" = "-" ]; then
    dst=/dev/stdout
elif [ -e "$2" ]; then
    log "Target already exists."
    exit 1
else
    dst="$2"
fi

if [ "$1" = "-" ] || [ -f "$1" ]; then
    if [ "$custom" = "" ]; then
        showusage
        exit 1
    else
        if [ ! -f "$custom" ] && [ ! -p "$custom" ]; then
            log "Unable to acquire custom installer script."
            exit 1
        fi
        
        custom="cat "$custom""
    fi
    
    if [ "$1" = "-" ]; then
        src=$(mktemp 2>/dev/null || mktemp -t "tmp.XXXXXXXXXX")
        addtemp "$src"
    
        cat - > "$src"
    else
        src="$1"
    fi
elif [ -d "$1" ]; then
    src=$(mktemp 2>/dev/null || mktemp -t "tmp.XXXXXXXXXX")
    addtemp "$src"

    tar cfz "$src" -C "$1" .
    
    custom="echo tar xfz \$tmp"
else 
    log "Unable to read from source."
    exit 1
fi

check=($(CMD_ENV=xpg4 cksum "$src"))
line=$(($(grep -n "#""MARKER:INSTALLER" "$0" | head -n 1 | cut -d ":" -f 1) + 1))

tail +$line "$0" \
    | sed -e "s;%%SUM%%;${check[0]};g" -e "s;%%SIZE%%;${check[1]};g" \
    | cat - <($custom) <(echo "exit") <(echo "#MARKER:PAYLOAD") $src > $dst

if [ -f "$dst" ]; then
    chmod a+x "$dst"
fi

exit

#MARKER:INSTALLER
#!/usr/bin/env bash
tmp=$(mktemp 2>/dev/null || mktemp -t "tmp.XXXXXXXXXX")

trap 'rm -f ${tmp}; exit 1' HUP INT QUIT TERM

line=$(($(grep -an "#""MARKER:PAYLOAD" "$0" | head -n 1  | cut -d ":" -f 1) + 1))

tail +$line "$0" > $tmp

scheck=(%%SUM%% %%SIZE%%)
pcheck=($(CMD_ENV=xpg4 cksum "$tmp"))

if [ ${scheck[0]} -ne ${pcheck[0]} ] || [ ${scheck[1]} -ne ${pcheck[1]} ]; then
    log "The installer is corrupted."
    exit 1
fi

