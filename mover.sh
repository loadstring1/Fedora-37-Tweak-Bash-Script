#!/bin/bash
scriptdir=$1
movedir=$2
mv "$movedir/*" "$scriptdir"
rm -rf "$scriptdir/UpdatedScript"
exec bash "$scriptdir/f37tweaks.sh"
exit