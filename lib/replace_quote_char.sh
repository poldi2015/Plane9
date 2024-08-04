#!/bin/bash

#
# Convert 7bit ascii quoted umlauts to utf8 umlauts
#
# -r or if named to_quote_latex.sh converts back to latex quotes
#

FILES=$*
if [ "$(basename $0)" = "to_quote_latex.sh" ]; then
  REVERT=1
fi
if [  "$1" = '-r' ]; then
  REVERT=1
  shift
  FILES=$*
fi
if [ "${*: -1}" = '-r' ]; then
  REVERT=1
  FILES=${*:1:$#-1}
fi

for i in $FILES; do
  if [ -z "$REVERT" ]; then
    cp "$i" "$i.7bit.bak"
    echo "Converting $i \"a  etc.  to ä..."
    ex +'%s/"a/ä/g' +'%s/"o/ö/g' +'%s/"u/ü/g' +'%s/"A/Ä/g' +'%s/"O/Ö/g' +'%s/"U/Ü/g' +'%s/\\3/ß/g' +'wq' $i
  else
    cp "$i" "$i.8bit.bak"
    echo "Converting $i ä  etc.  to \"a..."
    ex +'%s/ä/"a/g' +'%s/ö/"o/g' +'%s/ü/"u/g' +'%s/Ä/"A/g' +'%s/Ö/"O/g' +'%s/Ü/"U/g' +'%s/ß/\\3/g' +'wq' $i
  fi
done
