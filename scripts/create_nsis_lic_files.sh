#!/bin/sh

set -e

if [ -z "$1" ]; then
  echo "usage: $0 <vimdir>"
  exit 1
fi

VIMSRC=$1

cd "$VIMSRC/lang"
rm -f LICENSE.*.nsis.txt

for i in LICENSE.*.txt ../LICENSE; do
  # The files are UTF-8 already, add a BOM and CRLF
  name=${i##*/}
  target=${name%%.txt}.nsis.txt
  echo "Creating ${target}"
  { printf '\357\273\277'; sed 's/$/\r/' "$i"; } > "$target"
done
