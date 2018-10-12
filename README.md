# Preface

Tool for building self-contained installers.

# Usage

    usage: $(basename $0) [OPTIONS] [--] <source> <target>
    
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

    -q, --quiet     Less verbose output.
    -s, --script    Additional custom installer script. This argument is required
                    if the source is either a file or stdin. This argument is 
                    discarded if the source is a directory.
    -h, --help      Display this usage information.
        --version   Show version and exit.

