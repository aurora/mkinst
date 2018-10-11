#!/usr/bin/env bash

src="$1"
dst="test.bin"

check=($(CMD_ENV=xpg4 cksum "$src"))
line=$(($(grep -n "#""MARKER:INSTALLER" "$0" | head -n 1 | cut -d ":" -f 1) + 1))

tail +$line "$0" | sed -e "s;%%SUM%%;${check[0]};g" -e "s;%%SIZE%%;${check[1]};g" | cat - $src > $dst

chmod a+x $dst

exit

#MARKER:INSTALLER
#!/usr/bin/env bash
tmp=$(mktemp 2>/dev/null || mktemp -t "tmp.XXXXXXXXXX")

trap 'rm -f ${tmp}; exit 1' HUP INT QUIT TERM

line=$(($(grep -n "#""MARKER:PAYLOAD" "$0" | head -n 1  | cut -d ":" -f 1) + 1))

tail +$line "$0" > $tmp

scheck=(%%SUM%% %%SIZE%%)
pcheck=($(CMD_ENV=xpg4 cksum "$tmp"))

if [ ${scheck[0]} -ne ${pcheck[0]} ] || [ ${scheck[1]} -ne ${pcheck[1]} ]; then
    echo "the installer payload is corrupted."
    echo "aborting"
    exit 1
fi

exit

#MARKER:PAYLOAD
