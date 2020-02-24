. ./func/Hotip.sh
. ./config.sh
declare -A Mainarr
declare -A IPprio 
declare -A VirIPlist
Mainlist=()
declare -A Mainmap
IPfromstring=()
Colist=()
hotstr=''

if [[ $1 -eq Cores ]]  #Co-resident Mode
then
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
	if [[ ${Mainarr[Hotsubtype]} = "Hotsubtype=Samesubnet" ]]
	then
		Mainarr[VirIP]="VirIP=${IPfromstring[-1]}"		
		
		
				
		 
	fi

elif [[ $1 = 'NhotStan' ]] #Standalone mode with nms hotstandby
then
	fHotip "$2" 'NMShot'
	for f in ${!emsMap[@]}
	do
		if [[ ${emsMap[$f]} = 'Ishot' ]]
		then
			fHotip "$f" 'EMShot'
		
		else
		Mainmap[$f]="EMSnothot"
		fi
	done

elif [[ $1 = 'Stan' ]]
then
	Mainarr[TrapList]="TrapList=$1"
	for f in ${!emsMap[@]}
        do
                if [[ ${emsMap[$f]} = 'Ishot' ]]
                then
                        fHotip "$f" 'EMShot'
                
	        else
                Mainmap[$f]="EMSnothot"
        	fi
	done

fi

#MainPipeline. Extract all and convert
. ./config.sh

#Download corresponding builds in all servers
for j in ${!Mainmap[@]}
do
	if [[ "$j" != "${VirIPlist[0]}" &&  "$j" != "${VirIPlist[1]}" ]]       #Ignore for Virtual ips
        then
		DBuild $Israd $iip $bldvar $radbld &
	fi
done


for iip in ${!Mainmap[@]}
do
	if [[ "$iip" != "${VirIPlist[0]}" &&  "$iip" != "${VirIPlist[1]}" ]]       #Ignore for Virtual ips
	then
		
		#get Mode
		val=${Mainmap[$iip]}
		getmode=$(echo $val | cut -d' ' -f1)
		if [[ $getmode = NMShot
	fi

sshpass -f fsshpass ssh root@$iip "bash -s" < 
done
