#!/usr/bin/env bash

# 
# Tool for building self-contained installers.
# Copyright (C) 2018 by Harald Lapp <harald@octris.org>
#

version="0.0.1"
custom=""

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

-s, --script    Additional custom installer script. This argument is required
                if the source is either a file or stdin. This argument is 
                discarded if the source is a directory.
-h, --help      Display this usage information.
    --version   Show version and exit.
"
}

while [[ "${1:0:1}" = "-" ]]; do
    case $1 in
        -)
            break
            ;;
        --)
            shift
            break
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

if [ "$1" = "-" ] || [ -f "$1" ]; then
    if [ "$custom" = "" ]; then
        showusage
        exit 1
    else
        if [ ! -f "$custom" ] && [ ! -p "$custom" ]; then
            echo "Unable to acquire custom installer script."
            exit 1
        fi
        
        custom="cat "$custom""
    fi
    
    if [ "$1" = "-" ]; then
        src=$(mktemp 2>/dev/null || mktemp -t "tmp.XXXXXXXXXX")
    
        trap 'rm -f ${src}; exit 1' HUP INT QUIT TERM
    
        cat - > $src
    else
        src="$1"
    fi
elif [ -d "$1" ]; then
    src=$(mktemp 2>/dev/null || mktemp -t "tmp.XXXXXXXXXX")

    trap 'rm -f ${src}; exit 1' HUP INT QUIT TERM
    
    tar cfvz $src -C "$1" .
    
    custom="echo tar xfvz \$tmp"
else 
    echo "Unable to read from source."
    exit 1
fi

if [ "$2" = "-" ]; then
    dst=/dev/stdout
elif [ -e "$2" ]; then
    echo "Target already exists."
    exit 1
else
    dst="$2"
fi

check=($(CMD_ENV=xpg4 cksum "$src"))
line=$(($(grep -n "#""MARKER:INSTALLER" "$0" | head -n 1 | cut -d ":" -f 1) + 1))

tail +$line "$0" \
    | sed -e "s;%%SUM%%;${check[0]};g" -e "s;%%SIZE%%;${check[1]};g" \
    | cat - <($custom) <(echo "exit") <(echo "#MARKER:PAYLOAD") $src > $dst

chmod a+x $dst

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
    echo "The installer payload is corrupted."
    exit 1
fi

