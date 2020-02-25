#!/bin/bash
function ffresh
{
#First input argument should be installation type, second is NMS ips, ems ips will be passed thru emsMap globally
. ./func/Hotip.sh
. ./config.sh
. ./func/ethinter.sh
. ./func/DownBuild.sh

echo "poor ${!emsMap[@]} and ${emsMap[@]}"
unset Mainarr
declare -A Mainarr
declare -A IPprio 
declare -A VirIPlist
Virstr=''
Mainlist=()
declare -A Mainmap
IPfromstring=()
Colist=()
hotstr=''
echo "wtf is $1"
echo "atleast here"
if [[ $1 = 'Cores' ]]  #Co-resident Mode
then
	echo " wrong block boi"
	if [[ $3 -eq 0 ]] #No Hot mode
	then
	Ipstr=$(echo $4)
  	Mainarr[IsHot]="IsHot=n"
	Mainlist=("$Ipstr")
	else		#CoHot mode
	fHotip "$4"
	Mainlist=(${Colist[@]}p)
	 Mainarr[IsHot]="IsHot=y"
	Mainarr[Hotips]="Hotips=$hotstr"
	fi
	if [[ ${Mainarr[Hotsubtype]} = "Hotsubtype=Samesubnet" ]]
	then
		Mainarr[VirIP]="VirIP=${IPfromstring[-1]}"		
		
		
				
		 
	fi

elif [[ $1 = 'NhotStan' ]] #Standalone mode with nms hotstandby
then
	echo "in this block"
         echo "2: $2"
		
	fHotip "$2" 'NMShot'
	
	echo "${!emsMap[@]}"
	for f in "${!emsMap[@]}"
	do
		echo $f	
		if [[ "${emsMap[$f]}" = 'Ishot' ]]
		then
			fHotip "$f" 'EMShot'
		
		else
		echo "is this happening"
		Mainmap[$f]="EMSnothot"
		fi
	
	done

elif [[ $1 = 'Stan' ]]
then
	Mainarr[TrapList]="TrapList=$2"
	Mainmap[$2]=NMSnothot
	for f in "${!emsMap[@]}"
        do
                if [[ "${emsMap[$f]}" = 'Ishot' ]]
                then
                        fHotip "$f" 'EMShot'
                
	        else
                Mainmap[$f]="EMSnothot"
        	fi
	done

fi

#MainPipeline. Extract all and convert
. ./config.sh
echo "Israd: $Israd bldvar: $bldvar radbld: $radbld"
#Download corresponding builds in all servers
for j in "${!Mainmap[@]}"
do  
	echo "Input: $j"
	echo $Virstr | grep -w "$j"
	if [[ $? -ne 0 ]]       #Ignore for Virtual ips
        then
	echo "pass : $j"	
	#DBuild $Israd $j $bldvar $radbld &
	fi
done
wait

for iip in ${!Mainmap[@]}
do
	echo $Virstr | grep -w "$iip"
	if [[ $? -ne 0 ]]       #Ignore for Virtual ips
	then
		fethinter $iip #Mainarr[interface] set here for each ip
		
		#get Mode
		
		val="${Mainmap[$iip]}"
		getmode=$(echo $val | cut -d' ' -f1)
		
		if [[ $getmode = NMShot ]]
		then
			if [[ $rflag -eq 1 ]]
			then
				Mainarr[IMode]="IMode=5"
			else
				Mainarr[IMode]="IMode=2"
			fi
			Mainarr[NMSIMode]="NMSIMode=1"
			Mainarr[IsHot]="IsHot=y"
			Mainarr[Hotprio]="Hotprio=${IPprio[$iip]}"
			Mainarr[Build]="Build=$bldvar"
			if [[ `echo $val | cut -d' ' -f2` = 'Hotsubtype=MixedSubnet' ]]
                        then
				Mainarr[Hotsubtype]="Hotsubtype=MixedSubnet"
                                getstr=`echo $val | cut -d' ' -f3`
                                Mainarr[Hotips]="Hotips=$getstr"
                                getstr=`echo $val | cut -d' ' -f4`
                                Mainarr[MixedthisVirIP]="MixedthisVirIP=$getstr"
                                getstr=`echo $val | cut -d' ' -f5`
                                Mainarr[MixedthisIPs]="MixedthisIPs=$getstr"
                                getstr=`echo $val | cut -d' ' -f6`
                                Mainarr[MixedotherVirIP]="MixedotherVirIP=$getstr"
                                getstr=`echo $val | cut -d' ' -f7`
                                Mainarr[MixedotherIPs]="MixedotherIPs=$getstr"
                                #Mainarr[TrapList] set in Hotip.sh

                        elif [[ `echo $val | cut -d' ' -f2` = 'Hotsubtype=SameSubnet' ]]
                        then
				Mainarr[Hotsubtype]="Hotsubtype=SameSubnet"
                                getstr=`echo $val | cut -d' ' -f3`
                                Mainarr[Hotips]="Hotips=$getstr"
                                getstr=`echo $val | cut -d' ' -f4`
                                Mainarr[VirIP]="VirIP=$getstr"

                        elif [[ `echo $val | cut -d' ' -f2` = 'Hotsubtype=DifferentSubnet' ]]
                        then
				Mainarr[Hotsubtype]="Hotsubtype=DifferentSubnet"
                                getstr=`echo $val | cut -d' ' -f3`
                                Mainarr[Hotips]="Hotips=$getstr"
                        fi

		
		elif [[ $getmode = NMSnothot ]]
		then
			if [[ $rflag -eq 1 ]]
                        then
                                Mainarr[IMode]="IMode=5"
                        else
                                Mainarr[IMode]="IMode=2"
                        fi
			Mainarr[NMSIMode]="NMSIMode=1"
			Mainarr[IsHot]="IsHot=n"
			Mainarr[Build]="Build=$bldvar"
	
		elif [[ $getmode = EMShot ]]
		then
			Mainarr[IMode]="IMode=1"
			esub=$(echo $iip | cut -d'.' -f4)
			Mainarr[IsHot]="IsHot=y"
                        Mainarr[Hotprio]="Hotprio=${IPprio[$iip]}"
                        Mainarr[Build]="Build=$bldvar"
			if [[ `echo $val | cut -d' ' -f2` = 'Hotsubtype=MixedSubnet' ]]
			then
				Mainarr[Hotsubtype]="Hotsubtype=MixedSubnet"
				getstr=`echo $val | cut -d' ' -f3`
				Mainarr[Hotips]="Hotips=$getstr"
				getstr=`echo $val | cut -d' ' -f4`
				Mainarr[MixedthisVirIP]="MixedthisVirIP=$getstr"
				getstr=`echo $val | cut -d' ' -f5`
				Mainarr[MixedthisIPs]="MixedthisIPs=$getstr"
				getstr=`echo $val | cut -d' ' -f6`
				Mainarr[MixedotherVirIP]="MixedotherVirIP=$getstr"
				getstr=`echo $val | cut -d' ' -f7`
				Mainarr[MixedotherIPs]="MixedotherIPs=$getstr"
				#Mainarr[TrapList] set in Hotip.sh

			elif [[ `echo $val | cut -d' ' -f2` = 'Hotsubtype=SameSubnet' ]]
			then
				Mainarr[Hotsubtype]="Hotsubtype=SameSubnet"
				getstr=`echo $val | cut -d' ' -f3`
				Mainarr[Hotips]="Hotips=$getstr"
				getstr=`echo $val | cut -d' ' -f4`
				Mainarr[VirIP]="VirIP=$getstr"

			elif [[ `echo $val | cut -d' ' -f2` = 'Hotsubtype=DifferentSubnet' ]]
			then
				Mainarr[Hotsubtype]="Hotsubtype=DifferentSubnet"
				getstr=`echo $val | cut -d' ' -f3`
				Mainarr[Hotips]="Hotips=$getstr"
			fi
		elif [[ $getmode = EMSnothot ]]
		then
			Mainarr[IMode]="IMode=1"
			esub=$(echo $iip | cut -d'.' -f4)
                        Mainarr[EMSname]="EMSname=EMS-$esub"
			Mainarr[IsHot]="IsHot=n"
			Mainarr[Build]="Build=$bldvar"
						
		fi
	fi
echo "IP: $iip Mode: $getmode \n"
echo "${Mainarr[@]}"
echo $Virstr | grep -w "$iip"
if [[ $? -ne 0 ]]       #Ignore for Virtual ips
then
	echo "Installing in $iip"
	sshpass -f fsshpass ssh -o StrictHostKeyChecking=no root@$iip "bash -s" < ./eexp.sh "${Mainarr[@]}" |& tee Output_${iip}.txt &
fi
#echo "Virtualip list:  $Virstr"
echo " "
done	
}
