#!/bin/bash

pwout=$1
dos2unix $pwout 1 > /dev/null 2>&1
title=${pwout%.*}
log=$title".log"
title=${title##*/}

echo "! Generated with GVPW downloaded from http://bbs.keinsci.com/thread-20166-1-1.html" > $log
echo 'GradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGrad' >> $log
echo ' Number of steps in this run=     2333 maximum allowed number of steps=    2333.' >> $log

natline=`grep 'number of atoms/cell' $pwout`
nat=`echo $natline | awk '{print $5}'`
alatline=`grep 'lattice parameter (alat)' $pwout`
alat=`echo $alatline | awk '{print $5}'`
alat=`echo "$alat * 0.529177" | bc`
nline=`awk 'END{print NR}' $pwout`

nframe=0
BREAK=0
i=1
while [[ $i -le $nline ]];do
	thisline=`cat $pwout | sed -n $i"P"`
	thislinecut=`echo $thisline | awk '{print $1}'`
	if [[ $thisline == "     crystal axes: (cart. coord. in units of alat)" ]];then
		if [[ $BREAK == '1' ]];then
			break
		fi
		BREAK=1
		let i++
		thisthisline=`cat $pwout | sed -n $i"P"`
		x=`echo $thisthisline | awk '{print $4}'`
		x=`echo "$x * $alat" | bc`
		y=`echo $thisthisline | awk '{print $5}'`
		y=`echo "$y * $alat" | bc`
		z=`echo $thisthisline | awk '{print $6}'`
		z=`echo "$z * $alat" | bc`
		echo '1 Tv 0 '$x' '$y' '$z >> init_tmp_lat
		let i++
		thisthisline=`cat $pwout | sed -n $i"P"`
		x=`echo $thisthisline | awk '{print $4}'`
		x=`echo "$x * $alat" | bc`
		y=`echo $thisthisline | awk '{print $5}'`
		y=`echo "$y * $alat" | bc`
		z=`echo $thisthisline | awk '{print $6}'`
		z=`echo "$z * $alat" | bc`
		echo '1 Tv 0 '$x' '$y' '$z >> init_tmp_lat
		let i++
		thisthisline=`cat $pwout | sed -n $i"P"`
		x=`echo $thisthisline | awk '{print $4}'`
		y=`echo $thisthisline | awk '{print $5}'`
		z=`echo $thisthisline | awk '{print $6}'`
		echo "1 Tv 0 "`echo "$x * $alat" | bc`" "`echo "$y * $alat" | bc`" "`echo "$z * $alat" | bc` >> init_tmp_lat

	elif [[ $thisline == '     site n.     atom                  positions (alat units)' ]];then
		let geomend=$i+$nat
		let i++
		for j in `seq $i $geomend`;do
			thisthisline=`cat $pwout | sed -n $j"P"`
			e=`echo $thisthisline | awk '{print $2}'`
			x=`echo $thisthisline | awk '{print $7}'`
			y=`echo $thisthisline | awk '{print $8}'`
			z=`echo $thisthisline | awk '{print $9}'`
			echo "1 "$e" 0 "`echo "$x * $alat" | bc`" "`echo "$y * $alat" | bc`" "`echo "$z * $alat" | bc` >> init_tmp_atom
		done
		echo 'GradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGrad' >> $log
		echo '                          Input orientation:                          ' >> $log
		echo '---------------------------------------------------------------------' >> $log
		echo ' Center     Atomic      Atomic             Coordinates (Angstroms)' >> $log
		echo ' Number     Number       Type             X           Y           Z' >> $log
		echo ' ---------------------------------------------------------------------' >> $log
		cat init_tmp_atom >> $log
		cat init_tmp_lat >>$log
		echo ' ---------------------------------------------------------------------' >> $log

	elif [[ $thisline == 'CELL_PARAMETERS (angstrom)' ]];then
		let i++
		echo '1 Tv 0 '`cat $pwout | sed -n $i"P"` >> tmp_lat
		let i++
		echo '1 Tv 0 '`cat $pwout | sed -n $i"P"` >> tmp_lat
		let i++
		echo '1 Tv 0 '`cat $pwout | sed -n $i"P"` >> tmp_lat
		let i++
		let i++
		let geomend=$i+$nat
		let i++
		for j in `seq $i $geomend`;do
			echo '1 '`cat $pwout | sed -n $j"P" | awk '{print $1}'`' 0 '`cat $pwout | sed -n $j"P" | awk '{print $2}'`' '`cat $pwout | sed -n $j"P" | awk '{print $3}'`' '`cat $pwout | sed -n $j"P" | awk '{print $4}'`>> tmp_atom
		done
		let i=$geomend
		let i++
		thisthisline=`cat $pwout | sed -n $i"P"`
		if [[ $thisthisline != 'End final coordinates' ]];then
			echo 'GradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGrad' >> $log
			echo '                          Input orientation:                          ' >> $log
			echo '---------------------------------------------------------------------' >> $log
			echo ' Center     Atomic      Atomic             Coordinates (Angstroms)' >> $log
			echo ' Number     Number       Type             X           Y           Z' >> $log
			echo ' ---------------------------------------------------------------------' >> $log
			cat tmp_atom >> $log
			cat tmp_lat >> $log
			echo ' ---------------------------------------------------------------------' >> $log
		fi
		rm tmp_atom tmp_lat
		
	elif [[ $thisline == 'ATOMIC_POSITIONS (angstrom)' ]];then
		let geomend=$i+$nat
		let i++
		for j in `seq $i $geomend`;do
			echo '1 '`cat $pwout | sed -n $j"P" | awk '{print $1}'`' 0 '`cat $pwout | sed -n $j"P" | awk '{print $2}'`' '`cat $pwout | sed -n $j"P" | awk '{print $3}'`' '`cat $pwout | sed -n $j"P" | awk '{print $4}'`>> tmp_atom
		done
		let i=$geomend
		let i++
		thisthisline=`cat $pwout | sed -n $i"P"`
		if [[ $thisthisline != 'End final coordinates' ]];then
			echo 'GradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGrad' >> $log
			echo '                          Input orientation:                          ' >> $log
			echo '---------------------------------------------------------------------' >> $log
			echo ' Center     Atomic      Atomic             Coordinates (Angstroms)' >> $log
			echo ' Number     Number       Type             X           Y           Z' >> $log
			echo ' ---------------------------------------------------------------------' >> $log
			cat tmp_atom >> $log
			cat init_tmp_lat >> $log
			echo ' ---------------------------------------------------------------------' >> $log
		fi
		rm tmp_atom

	elif [[ $thislinecut == "!" ]];then
		let nframe++
		thisenergy=`echo $thisline | awk '{print $5}'`
		echo ' SCF Done:  E(???) =  '$thisenergy'     A.U. after   2333 cycles' >> $log
		echo 'GradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGrad' >> $log
		echo ' Step number  '$nframe' out of a maximum of  2333' >> $log
	fi
	let i++
done


echo ' Optimization completed.' >> $log
echo '    -- Stationary point found.' >> $log
echo 'GradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGrad' >> $log
echo 'Normal termination of Gaussian' >> $log

rm init_tmp_lat init_tmp_atom


#unix2dos $log
