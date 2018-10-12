# mkinst

This tool can be used to create self-contained installers.

## Usage

    usage: mkinst [OPTIONS] [--] <source> <target>

    Creates a self-contained installer from the specified source and stores it to
    the specified target.

    ARGUMENTS

        <source>            Expects a file-name, a directory name or '-' for stdin.
                            If the name of a directory is specified, the tool will
                            create a tar archive from it. If the source is no direc-
                            tory an additional custom installer script needs to be
                            added using the options '-i' or '--include'.

        <target>            Either a file-name or '-' for stdout.

    OPTIONS

        -q, --quiet         Less verbose output.
        -s, --shell ARG     Shell to use for installer (default: /bin/sh).
                            Make sure that the shell is available on the target
                            system. The specified path should be valid to use as
                            shebang.
        -i, --include ARG   Additional custom installer script to include. This
                            option is required if the source is either a file or
                            stdin. It is optional if the source is a directory.
        -h, --help          Display this usage information.
            --version       Show version and exit.

## License

*Note: while this script is distributed under the GPL-3 license, the generated
installation script is distributed under the MIT license.*

Copyright (C) 2018 by Harald Lapp <harald@octris.org>

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
