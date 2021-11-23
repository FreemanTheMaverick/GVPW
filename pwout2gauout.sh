#!/bin/bash

pwout=$1
dos2unix $pwout 1 > /dev/null 2>&1
title=${pwout%.*}
log=$title".log"
title=${title##*/}

echo "! Generated with GVPW downloaded from https://github.com/FreemanTheMaverick/GVPW.git" > $log
echo 'GradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGrad' >> $log
echo ' Number of steps in this run=     2333 maximum allowed number of steps=    2333.' >> $log

natline=`grep 'number of atoms/cell' $pwout` # Finding the line containing the number of atoms/cell.
nat=`echo $natline | awk '{print $5}'` # Finding the number of atoms/cell.
alatline=`grep 'lattice parameter (alat)' $pwout` # Similar to above.
alat=`echo $alatline | awk '{print $5}'`
alat=`echo "$alat * 0.529177" | bc` # Converting unit of alat from Bohr to Angstrom.
nline=`awk 'END{print NR}' $pwout`

nframe=0 # Number of frames.
BREAK=0 # Whether to stop searching for new frames.
i=1
while [[ $i -le $nline ]];do
	thisline=`cat $pwout | sed -n $i"P"`
	thislinecut=`echo $thisline | awk '{print $1}'` # The first string of this line.
	if [[ $thisline == "     crystal axes: (cart. coord. in units of alat)" ]];then # Finding the inital lattice vectors.
		if [[ $BREAK == '1' ]];then # The string appears in two places, the beginning and the end. When it appears for the second time, it will be time to stop searching and break the loop.
			break
		fi
		BREAK=1 # For the first time encountering the string, toggling BREAK to true.
		let i++ # Moving to next line, which contains lattice vectors.
		thisthisline=`cat $pwout | sed -n $i"P"`
		x=`echo $thisthisline | awk '{print $4}'`
		x=`echo "$x * $alat" | bc` # Converting unit of lattice vectors from alat to Angstrom.
		y=`echo $thisthisline | awk '{print $5}'`
		y=`echo "$y * $alat" | bc`
		z=`echo $thisthisline | awk '{print $6}'`
		z=`echo "$z * $alat" | bc`
		echo '1 Tv 0 '$x' '$y' '$z >> init_tmp_lat # Putting lattice vectors of the first frame to init_tmp_lat
		let i++ # Similar to above.
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
		echo "1 Tv 0 "`echo "$x * $alat" | bc`" "`echo "$y * $alat" | bc`" "`echo "$z * $alat" | bc` >> init_tmp_lat # Same function, but different ways of coding.

	elif [[ $thisline == '     site n.     atom                  positions (alat units)' ]];then # Finding the first molecular geometry.
		let geomend=$i+$nat # The last line containing molecular geometry.
		let i++ # The first line containing molecular geometry.
		for j in `seq $i $geomend`;do # Scanning all lines containing molecular geometry of current frame.
			thisthisline=`cat $pwout | sed -n $j"P"`
			e=`echo $thisthisline | awk '{print $2}'` # Element symbol.
			x=`echo $thisthisline | awk '{print $7}'` # X coordinate.
			y=`echo $thisthisline | awk '{print $8}'` # Y coordinate.
			z=`echo $thisthisline | awk '{print $9}'` # Z coordinate.
			echo "1 "$e" 0 "`echo "$x * $alat" | bc`" "`echo "$y * $alat" | bc`" "`echo "$z * $alat" | bc` >> init_tmp_atom # Converting unit of coordinates from alat to Angstrom.
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

	elif [[ $thisline == 'CELL_PARAMETERS (angstrom)' ]];then # Two kinds of geometry optimization are considered in the script, 'vc-relax' and 'relax'. In 'vc-relax', both 'ATOMIC_POSITIONS' but no 'CELL_PARAMETERS' are printed for each frame, while in 'relax', only 'ATOMIC_POSITIONS' is printed for each frame. This if-branch is for 'vc-relax'.
		let i++ # Putting lattice vectors into tmp_lat.
		echo '1 Tv 0 '`cat $pwout | sed -n $i"P"` >> tmp_lat
		let i++
		echo '1 Tv 0 '`cat $pwout | sed -n $i"P"` >> tmp_lat
		let i++
		echo '1 Tv 0 '`cat $pwout | sed -n $i"P"` >> tmp_lat
		let i++
		let i++
		let geomend=$i+$nat # Finding 'ATOMIC_POSITIONS' of this frame.
		let i++
		for j in `seq $i $geomend`;do
			echo '1 '`cat $pwout | sed -n $j"P" | awk '{print $1}'`' 0 '`cat $pwout | sed -n $j"P" | awk '{print $2}'`' '`cat $pwout | sed -n $j"P" | awk '{print $3}'`' '`cat $pwout | sed -n $j"P" | awk '{print $4}'`>> tmp_atom # Putting molecular geometry into tmp_atom.
		done
		let i=$geomend # Putting the pointer i beyond 'ATOMIC_POSITIONS' so it will not locate 'ATOMIC_POSITIONS' again in the next if-branch.
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
		
	elif [[ $thisline == 'ATOMIC_POSITIONS (angstrom)' ]];then # Two kinds of geometry optimization are considered in the script, 'vc-relax' and 'relax'. In 'vc-relax', both 'ATOMIC_POSITIONS' but no 'CELL_PARAMETERS' are printed for each frame, while in 'relax', only 'ATOMIC_POSITIONS' is printed for each frame. This if-branch is for 'relax'.
		let geomend=$i+$nat # Finding molecular geometry of this frame.
		let i++
		for j in `seq $i $geomend`;do
			echo '1 '`cat $pwout | sed -n $j"P" | awk '{print $1}'`' 0 '`cat $pwout | sed -n $j"P" | awk '{print $2}'`' '`cat $pwout | sed -n $j"P" | awk '{print $3}'`' '`cat $pwout | sed -n $j"P" | awk '{print $4}'`>> tmp_atom # Putting molecular geometry into tmp_atom.
		done
		let i=$geomend
		let i++
		thisthisline=`cat $pwout | sed -n $i"P"`
		if [[ $thisthisline != 'End final coordinates' ]];then # In the end of 'vc-relax' and 'relax', the final molecular geometry is printed twice. The second one, which is followed by 'End final coordinates', should be discarded.
			echo 'GradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGradGrad' >> $log
			echo '                          Input orientation:                          ' >> $log
			echo '---------------------------------------------------------------------' >> $log
			echo ' Center     Atomic      Atomic             Coordinates (Angstroms)' >> $log
			echo ' Number     Number       Type             X           Y           Z' >> $log
			echo ' ---------------------------------------------------------------------' >> $log
			cat tmp_atom >> $log
			cat init_tmp_lat >> $log # In 'relax', initial lattice vectors are reused for each frame.
			echo ' ---------------------------------------------------------------------' >> $log
		fi
		rm tmp_atom

	elif [[ $thislinecut == "!" ]];then
		let nframe++ # Number of frame increases.
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
