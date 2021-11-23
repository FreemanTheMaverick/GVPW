#!/bin/bash

pwout=$1
dos2unix $pwout 1 > /dev/null 2>&1
title=${pwout%.*}
log=$title".log"
title=${title##*/}

echo "! Generated with pwout2log.sh downloaded from http://bbs.keinsci.com/thread-20166-1-1.html" > $log
echo '0 basis functions' >> $log
echo '0 alpha electrons' >> $log
echo '0 beta electrons' >> $log
echo 'GradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGrad' >> $log

nat=`grep 'number of atoms/cell' $pwout | awk '{print $5}'`
alat=`grep 'lattice parameter (alat)' $pwout | awk '{print $5}'`
alat=`echo "$alat * 0.529177" | bc`
nline=`awk 'END{print NR}' $log`

while [ $i -le $nline ];do
	thisline=`cat $log | sed -n $i"P"`
	if [[ $thisline == "     crystal axes: (cart. coord. in units of alat)" ]];then
		let i++

	elif [[ $thisline == 'CELL_PARAMETERS (angstrom)' ]];then
		let i++
		echo '1 Tv 0 '`cat $log | sed -n $i"P"` >> tmp_lat
		let i++
		echo '1 Tv 0 '`cat $log | sed -n $i"P"` >> tmp_lat
		let i++
		echo '1 Tv 0 '`cat $log | sed -n $i"P"` >> tmp_lat
		let i++
		let i++
		let geomend=i+nat
		let i++
		for j in `seq $i $geomend`;do
			echo '1 '`cat $log | sed -n $j"P" | awk '{print $1}'`' 0 '`cat $log | sed -n $j"P" | awk '{print $2}'``cat $log | sed -n $j"P" | awk '{print $3}'``cat $log | sed -n $j"P" | awk '{print $4}'`>> tmp_atom
		done
		let i=$geomend
		echo 'GradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGrad' >> $log
		echo '---------------------------------------------------------------------' >> $log
		echo ' Center     Atomic      Atomic             Coordinates (Angstroms)' >> $log
		echo ' Number     Number       Type             X           Y           Z' >> $log
		echo ' ---------------------------------------------------------------------' >> $log
		cat tmp_atom >> $log
		cat tmp_lat >>$log
		echo ' ---------------------------------------------------------------------' >> $log
		rm tmp_atom tmp_lat
		
	elif [[ 

endline=`cat $pwout | grep -n 'End final coordinates' | awk -F ":" '{print $1}'`
startline=$(expr $endline - $nat)
endline=$(expr $endline - 1)
for i in `seq $startline $endline`;do
	echo `sed -n $i"p" $pwout` >> $log
done

echo "" >> $log
echo "" >> $log

#unix2dos $log
