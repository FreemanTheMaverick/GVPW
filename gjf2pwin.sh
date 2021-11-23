#!/bin/bash

gjf=$1
dos2unix $gjf 1 > /dev/null 2>&1
title=${gjf%.*}
pwin=$title".in"
title=${title##*/}

nline=`awk 'END{print NR}' $gjf`
i=1
n=0
while [ $i -le $nline ];do # Starting from the beginning of gjf.
	thisline=`cat $gjf | sed -n $i"P"`
	if [[ -z $thisline ]];then
		let n++
	fi
	if [ $n -eq 2 ];then
		let i++ # Charge and multiplicity entry found.
		let i++ # The first line of molecular geometry found.
		break
	else
		let i++
	fi
done
while [ $i -le $nline ];do # Starting from the first line of molecular geometry.
	thisline=`cat $gjf | sed -n $i"P"`
	if [[ -z $thisline ]];then # The end of molecular geometry found.
		break
	else
		thislinecut=`echo $thisline | awk '{print $1}'`
		if [[ $thislinecut == 'Tv' ]];then
			echo "$thisline" >> tmp_lat # Putting the lattice constants to tmp_lat.
		else
			echo "$thisline" >> tmp_atom # Putting the atomic coordinates to tmp_atom.
		fi
		let i++ # Moving to the next line.
	fi
done

sed -i 's/Tv//g' tmp_lat # Removing all 'Tv' from tmp_lat.

settings=$2
dos2unix $settings 1 > /dev/null 2>&1
nat=`grep 'nat' $settings | awk '{print $3}'` # Number of atoms found at the third entry of the line containing 'nat'.
nline=`awk 'END{print NR}' $settings` # Number of lines contained in $2.
echo '! Generated with gjf2pwin.sh downloaded from' > $pwin
echo '! http://bbs.keinsci.com/thread-20166-1-1.html' >> $pwin
j=1
while [ $j -le $nline ];do
	thisline=`cat $settings | sed -n $j"P"`
	thislinecut=`echo $thisline | awk '{print $1}'`
	if [[ $thislinecut == 'ATOMIC_POSITIONS' ]];then # The entry 'ATOMIC_POSITIONS' found.
		let j++ # The first line of molecular geometry found.
		let j=j+$nat # Skipping the molecular geometry in settings.
	elif [[ $thislinecut == 'CELL_PARAMETERS' ]];then # The entry 'CELL_PARAMETERS' found.
		let j++
		let j++
		let j++
		let j++ # Skipping the lattice constants in settings.
	else
		echo $thisline >> $pwin
		let j++ # Moving to the next line.
	fi
done

echo "ATOMIC_POSITIONS angstrom" >> $pwin
nline=`awk 'END{print NR}' tmp_atom`
for i in `seq 1 $nline`;do
	echo `sed -n $i"P" tmp_atom` >> $pwin # Putting molecular geometry in tmp_atom to target.
done

nat=$nline
line=`cat $pwin | grep -n 'nat' | awk -F ":" '{print $1}'`
sed -i "$line"c" nat = $nat" $pwin

echo "CELL_PARAMETERS angstrom" >> $pwin
nline=`awk 'END{print NR}' tmp_lat`
for i in `seq 1 $nline`;do
	echo `sed -n $i"P" tmp_lat` >> $pwin # Putting lattice constants in tmp_atom to target.
done
rm tmp_atom tmp_lat

#unix2dos $pwin 1 > /dev/null 2>&1

