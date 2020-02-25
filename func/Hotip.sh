function fHotip
{
#declare -A Mainarr
#declare -A VirIPlist
#declare -A IPprio
#declare -A Mainmap
#IPfromstring=()
#Colist=()
#hotstr=''
echo "Hotip fir arg: $1"
echo "Hotip sec arg: $2"
local alen
local prio
usrinp=$(echo $1)
echo "Userinp: $usrinp"
spacecount=$(echo $usrinp | tr -cd ' \t' | wc -c)
no=$((spacecount+1))
a=$((no-1))
echo "Spacecount: $spacecount"
unset IPfromstring
while (( $no > 0 ))
do
IPfromstring[$a]=$(echo $usrinp | cut -d' ' -f$no)
no=$((no-1))
a=$((a-1))
done
echo "IParray: ${IPfromstring[@]}"

samesub=0
difsub=0
alen=${#IPfromstring[@]}
for u in "${!IPfromstring[@]}"
do
	g=$((u+1))
	al=$((g+1))
	while (( $al <= $alen ))
	do	
		sub1=$(echo ${IPfromstring[$u]} | cut -d'.' -f4 --complement)
		sub2=$(echo ${IPfromstring[$g]} | cut -d'.' -f4 --complement)
		echo "sub1: $sub1 & sub2: $sub2"
		if [[ "$sub1" = "$sub2" ]]
		then
		samesub=1
	
		else
		difsub=1
		fi
		g=$((g+1))
		al=$((g+1))
		
	done
done
Colist=()
if [[ $samesub -eq 1 && $difsub -eq 0 ]]
then
	echo "Its samesubnet"
	Mainarr[Hotsubtype]=Hotsubtype=SameSubnet
	hln=${#IPfromstring[@]}
	hln=$((hln-1))
	Colist=("${IPfromstring[@]:0:$hln}")
	hotstr=$(echo ${Colist[@]} | tr ' ' ',')
	VirIPlist[0]=${IPfromstring[-1]}
	Virstr="$Virstr ${VirIPlist[0]}"
elif [[ $samesub -eq 0 && $difsub -eq 1 ]]
then
	echo "Its different subnet"
	Mainarr[Hotsubtype]=Hotsubtype=DifferentSubnet
	Colist=(${IPfromstring[@]})
	hotstr=$(echo ${Colist[@]} | tr ' ' ',')
	if [[ $2 = 'NMShot' ]]
        then
				ll=$(echo ${Colist[@]} | tr ' ' ',')
                                Mainarr[TrapList]="TrapList=$ll"
        fi


elif [[ $samesub -eq 1 && $difsub -eq 1 ]]
then
	echo "Its mixed subnet"
	Mainarr[Hotsubtype]=Hotsubtype=MixedSubnet
	Colist=(${IPfromstring[@]})
        hotstr=$(echo ${Colist[@]} | tr ' ' ',')
	
fi

#If Mixed Mode fish out the multiple Virtual IPs
if [[ ${Mainarr[Hotsubtype]} = 'Hotsubtype=MixedSubnet' ]]
then
	 subi=$(echo ${IPfromstring[0]} | cut -d'.' -f4 --complement)                   #Get Subnet of first IP
	for (( h=1; h<${#IPfromstring[@]};h++ ))
	do
		subn=$(echo ${IPfromstring[$h]} | cut -d'.' -f4 --complement)
		if [[ $subi != $subn ]]
		then
			h=$((h-1))
			VirIPlist[0]=${IPfromstring[$h]}
			VirIPlist[1]=${IPfromstring[-1]}
			Virstr="$Virstr ${VirIPlist[@]}"
			if [[ $2 = 'NMShot' ]]
			then
				Mainarr[TrapList]="TrapList=${VirIPlist[0]},${VirIPlist[1]}"
			fi
			break
		fi
	done

	#Generate Samesubnet list and different subnet list
	declare -A subnetmap
	Samestr=''
	Diffstr=''
	for h in ${IPfromstring[@]}
	do
		filt1=$(echo ${VirIPlist[0]} | cut -d'.' -f4 --complement)
		filt2=$(echo ${VirIPlist[1]} | cut -d'.' -f4 --complement)
		subh=$(echo $h | cut -d'.' -f4 --complement)
		if [[ $subh = $filt1 ]]
		then
			if [[ $h != ${VirIPlist[0]} ]]
			then
				Samestr="$Samestr$h "
			fi
		elif [[ $subh = $filt2 ]]
		then
			if [[ $h != ${VirIPlist[1]} ]]
                        then
                                Diffstr="$Diffstr$h "
                        fi
		fi 
	done
	Samestr=$(echo $Samestr | tr ' ' ',')
	Diffstr=$(echo $Diffstr | tr ' ' ',')
	
	subnetmap[$filt1]=$Samestr
	subnetmap[$filt2]=$Diffstr
fi

if [[ $2 = EMShot ]]
then
	subetr=$(echo ${Colist[0]} | cut -d'.' -f4)
	Mainarr[EMSname]="EMSname=EMS-$subetr"
fi

prio=9

hotstr=''
hotarray=()
o=0
#Start building mainmap, filtering out the virtual ips
echo "Colist: ${Colist[@]}"
for y in ${Colist[@]}
do
if [[ "$y" != "${VirIPlist[0]}" &&  "$y" != "${VirIPlist[1]}" ]]
then
	echo "Check from here"
	echo "y: $y and 2: $2 and prio: $prio"	
	Mainmap[$y]="$2 ${Mainarr[Hotsubtype]}"	
	IPprio[$y]=$prio
	prio=$((prio-1))
	hotstr="$hotstr $y"
	hotarray[$o]=$y
	o=$((o+1))
fi
done
hotstr=$(echo $hotstr | tr ' ' ',')

#Add virtual ip info,build Mainmap futher, finally
if [[ ${Mainarr[Hotsubtype]} = 'Hotsubtype=MixedSubnet' ]]
then 
	for y in ${Colist[@]}
	do	
		echo "next step"
		echo "y: $y"
		Mainmap[$y]="${Mainmap[$y]} $hotstr"	
		echo "Mainmap now: ${Mainmap[$y]}"
	done
	
	#Build thisips and thatips and build into mainmap
	for o in ${hotarray[@]}
	do
		echo "o: $o and Main[o]: ${Mainmap[$o]}"
		subo=$(echo $o | cut -d'.' -f4 --complement)
		if [[ $subo = $filt1 ]]
		then
			
			Mainmap[$o]="${Mainmap[$o]} ${VirIPlist[0]} ${subnetmap[$filt1]} ${VirIPlist[1]} ${subnetmap[$filt2]}"       
			echo "after o: $o and ${Mainmap[$o]}"
		elif [[ $subo = $filt2 ]]
		then
			Mainmap[$o]="${Mainmap[$o]} ${VirIPlist[1]} ${subnetmap[$filt2]} ${VirIPlist[0]} ${subnetmap[$filt1]}"
			echo "after o: $o and ${Mainmap[$o]}"
		fi
	done

elif [[ ${Mainarr[Hotsubtype]} = 'Hotsubtype=SameSubnet' ]]
then
	for y in ${Colist[@]}
	do
		hotstr=$(echo ${Colist[@]} | tr ' ' ',')
		Mainmap[$y]="${Mainmap[$y]} $hotstr ${VirIPlist[0]}"
	done

elif [[ ${Mainarr[Hotsubtype]} = 'Hotsubtype=DifferentSubnet' ]]
then
	for y in ${Colist[@]}
	do
	 	hotstr=$(echo ${Colist[@]} | tr ' ' ',')
		Mainmap[$y]="${Mainmap[$y]} $hotstr"
	done	
fi
unset Colist
}	
