#!/bin/bash

pwin=$1
dos2unix $pwin 1 > /dev/null 2>&1
title=${pwin%.*}
gjf=$title".gjf"
title=${title##*/}

echo "# pbepbe/3-21g/auto" > $gjf
echo "" >> $gjf
echo "${title}" >> $gjf
echo "Generated with pwin2gjf.sh downloaded from http://bbs.keinsci.com/thread-20166-1-1.html" >> $gjf
echo "" >> $gjf
echo "0 1" >> $gjf

nat=`grep 'nat' $pwin | awk '{print $3}'`

startline=`cat $pwin | grep -n 'ATOMIC_POSITIONS' | awk -F ":" '{print $1}'` # Finding the line containing 'ATOMIC_POSITIONS'.
let endline=$startline+$nat # Finding the line where molecular geometry ends.
let startline=$startline+1 # Finding the line where molecular geometry begins.
for i in `seq $startline $endline`;do
	echo `sed -n $i"P" $pwin` >> $gjf # Putting molecular geometry into gjf.
done

startline=`cat $pwin | grep -n 'CELL_PARAMETERS' | awk -F ":" '{print $1}'` # Finding the line containing 'CELL_PARAMETERS'.
let endline=$startline+3 # Finding the line where lattice vectors end.
let startline=$startline+1 # Finding the line where lattice vectors begin.
for i in `seq $startline $endline`;do
	echo 'Tv '`sed -n $i"P" $pwin` >> $gjf # Putting lattice vectors into gjf.
done

echo "" >> $gjf
echo "" >> $gjf

#unix2dos $gjf 1 > /dev/null 2>&1



