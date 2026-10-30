#!/bin/sh

set -e

if [ -z "$1" ]; then
  echo "usage: $0 <vimdir>"
  exit 1
fi

VIMSRC=$1

cd "$VIMSRC/lang"
rm -f LICENSE.*.nsis.txt LICENSE.nsis.txt

for i in LICENSE.*.txt; do
  # The files are UTF-8 already, add a BOM and CRLF
  target=${i%%.txt}.nsis.txt
  echo "Creating ${target}"
  { printf '\357\273\277'; sed 's/$/\r/' "$i"; } > "$target"
done

# The Vim license must be included unmodified, see II.1) of it
echo "Creating LICENSE.nsis.txt"
{
  printf '\357\273\277'
  cat <<'EOF'
ViAI is a modified version of Vim.

Changes made in ViAI after the initial import are licensed under the Apache
License 2.0.  Code imported from Vim is licensed under the Vim license.  Both
licenses follow.


EOF
  cat ../LICENSE
  printf '\n\n'
  cat ../LICENSE-APACHE
} | sed 's/$/\r/' > LICENSE.nsis.txt
