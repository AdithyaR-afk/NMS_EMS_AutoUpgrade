#!/bin/bash
. ./fresh.sh
Isco=0
Isfresh=0
Ishot=0
Isstan=0
Ise=0
Isfresh=0
Isn=0
bopt=0
Israd=0
radbld=''
nmshot=0
emshot=0
declare -A emsMap
echo $@

function EHotflush
{
if [[ $Ishot -eq 1 ]]
then
	emsMap["$OPTARG"]='Ishot'
	Ishot=0                      #FLush Ishot for next input
	emshot=1
else
	emsMap["$OPTARG"]='Isnothot'
fi
}
function NHotflush
{
if [[ $Ishot -eq 1 ]]
then
        nmshot=1
	Ishot=0
fi
}
while getopts ":fc:hse:n:b:r:" opt; do
case $opt in
	c) Isco=1; Coips=$OPTARG ;;
	f) Isfresh=1;;
	s)Isstan=1;;
	e)Ise=1; EHotflush;;                                           #Eips=$OPTARG;;
	n)Isn=1; NHotflush; Nips=$OPTARG;;
	h)Ishot=1;;
	b)bopt=1;bldvar=$OPTARG;;
	r)Israd=1;radbld=$OPTARG;;
	\?) echo "Help/Wrong option";;
	:) echo "Optio ${OPTARG} requires argument"
esac
done
echo $Ishot
echo "Optind : $OPTIND"
echo "bopt: $bopt"
if [[ -z $bldvar ]]
then
echo "Enter proper build after -b"
exit 1
fi

if [[ $Israd -eq 1 && -z $radbld ]]
then
echo "Enter proper build after -r"
exit 1
fi

#allowed modes
if [[ $Isfresh -eq 1 ]]
then	
	echo "Its fresh"
	if [[ $Isco -eq 1 && $Isstan -eq 1 ]]
        then
                echo "Double options entered"
                exit 1
        fi
	if [[ $Isco -eq 0 && $Isstan -eq 0 ]]
	then
		echo "Specify proper arguments like -fc 'Ips' or -fsn 'Ips' -e 'Ips'"
		exit 1
	fi
	
	if [[ $Isco -eq 1 && $Ishot -eq 0 ]]
	then
	echo "Installing Co-resident mode without Hotstandby"
		if [[ -z $Coips ]]
                then
                echo "Enter all ips within quotes after -c"
                exit 1
                
		
		elif [[ $Coips =~ [s] ]]
		then
		echo "You cannot combine c mode and s mode!"
		echo "COIPS: $Coips"
		exit 1
		fi
		
		ffresh 'Cores' "$Coips"

	elif [[ $Isco -eq 1 && $Ishot -eq 1 ]]
	then
	echo "Installing Co-resident mode with Hotstandby"
		if [[ -z $Coips ]]
		then
		echo "Enter all ips in quotes after -c"
		exit 1

                elif [[ $Coips =~ [s] ]]
                then
                echo "You cannot combine c mode and s mode!"
                echo "COIPS: $Coips"
                exit 1
                fi

		ffresh 'Cohot' "$Coips"
		

	elif [[ $Isstan -eq 1 ]]
	then
	echo "Installing Standalone mode without Hotstandby"
		echo "emsmap: $emsMap and Nips: $Nips"
		if [[ -z ${emsMap[@]} || -z $Nips ]]
		then
		echo "Enter ems ips within quotes after -e and nms ips within quotes after -n"
		exit 1
		fi
		
		 if [[ ${!emsMap[@]} =~ [a-z] || $Nips =~ [a-z] ]]
                then
                echo "Enter proper ip after -e and -n"
                exit 1
                fi
	echo "NMSIPS: $Nips and EMSIPS: ${!emsMap[@]} "
		if [[ $nmshot -eq 1 ]]
		then
		ffresh 'NhotStan' "$Nips"             #Passing emsMap[] by default	
		else
		ffresh 'Stan' "$Nips"			#Passing emsMap[] by default
		fi
	fi

elif [[ $Isfresh -eq 0 ]]
then
echo "Specifiy type of instalaation as frsh with -f"
exit 1
fi



