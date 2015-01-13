#!/bin/bash

cd src/csm
for file in $(find . -name "*.h"); do
  dir=`dirname $file`
  destdir=../../include/csm/$dir
  basefile=`basename $file`
  mkdir -p $destdir
  mv $file $destdir/$basefile
done
cd -
