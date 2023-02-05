#!/bin/bash
scriptdir=$1
movedir=$2
cp -r "$movedir/"* "$scriptdir"
exit
rm -rf "$scriptdir/UpdatedScript"
cd "$scriptdir"
exec bash "$scriptdir/f37tweaks.sh"
exit
