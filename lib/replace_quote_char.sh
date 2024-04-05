#!/bin/bash

#
# Convert 7bit ascii quoted umlauts to utf8 umlauts
#
# -r convert to unicode
#

if [ "$1" = '-r' ]; then
  REVERT=1
  shift  
fi

for i in $*; do
  if [ -z "$REVERT" ]; then
    echo "Converting $i \"a  etc.  to ä..."
    ex +'%s/"a/ä/g' +'%s/"o/ö/g' +'%s/"u/ü/g' +'%s/"A/Ä/g' +'%s/"O/Ö/g' +'%s/"U/Ü/g' +'%s/\\3/ß/g' +'wq' $i
  else
    echo "Converting $i ä  etc.  to \"a..."
    ex +'%s/ä/"a/g' +'%s/ö/"o/g' +'%s/ü/"u/g' +'%s/Ä/"A/g' +'%s/Ö/"O/g' +'%s/Ü/"U/g' +'%s/ß/\\3/g' +'wq' $i
  fi
done
