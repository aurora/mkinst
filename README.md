# mkinst

This tool can be used to create self-contained installers. While mkinst
itself requires a bash, the created installer supplied with the installation
package is POSIX compliant and should be usable with a POSIX compliant shell.

## Usage

    usage: mkinst [OPTIONS] [--] <target> <source> [<source> ...]
    usage: mkinst [OPTIONS] -w -i ARG [--] <target> <source>
    
    Creates a self-contained installer from the specified sources and stores it to
    the specified target.

    ARGUMENTS

        <target>            Either a file-name or '-' for stdout.
        <source>            One or multiple file or directory names.

    OPTIONS

        -q, --quiet         Less verbose output.
        -s, --shell ARG     Shell to use for installer (default: /bin/sh).
                            Make sure that the shell is available on the target
                            system. The specified path should be valid to use as
                            shebang.
        -i, --include ARG   Additional custom installer script to include.
        -c, --compress ARG  Compression level 1-9 to use (default: 6), whereat 1
                            defines the fastest and 9 defines the best compression.
        -w, --wrap          Wrap the specified source in an installer without using
                            tar internally to create an installation package. Note
                            that this argument requires a custom installer script
                            as the installer can't know how to handle the wrapped
                            payload. Also the compression is ignored.
        -h, --help          Display this usage information.
            --version       Show version and exit.

## Examples

Please have a look at the following build scripts to see what's possible:

* https://github.com/aurora/mkinst/blob/master/build.sh
* https://github.com/aurora/caddy.sh/blob/master/build.sh

## API

By default mkinst will create a tar package from the specified sources and the created installer contains code to untar
the package. It's possible to extend the functionality of the created installer by specifying a custom script using
the `-i` or `--include` argument for mkinst. The main part of the created installer is POSIX compliant and defines the
following functions that can be called from the custom include script.

*   **add_temp ARG1** -- Remember the specified filename (ARG1) as temporary file that needs to be removed when installer exits
*   **cleanup_temp** -- Remove temporary files. Note that this function is registered as exit handler by the installer. So normally there should be no reason to call this function as it is automatically called when the installer exits.
*   **untar_payload \[ARG1\]** -- This function contains the code to uncompress and install the payload. The argument is optional and defines the path to uncompress the payload in. By default the path is "/".

## License

*Note: while this script is distributed under the GPL-3 license, the generated
installation script is distributed under the MIT license.*

Copyright (C) 2018 by Harald Lapp <harald@octris.org>

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
