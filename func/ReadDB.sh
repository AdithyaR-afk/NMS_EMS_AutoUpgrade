function fReadDB
{ 
#IPAR=(192.168.3.204 192.168.228.31 192.168.3.24)
#Eno=2
#argument to the function is Eno (noof emss)
path=$(echo `pwd`)

yes | unzip $path/*.zip > /dev/null 2>&1
yes | gunzip $path/*.gz > /dev/null 2>&1

#rm -rf $path/DB
#mkdir $path/DB

#Extract all sql files and move to $ath/DB
find $path -ctime -1 -name "*.sql" | xargs -I '{}' mv '{}' $path/DB/

cd $path/DB
count=$(ls | wc -l)
echo "Count $count"
#need to loop this section
#need to have code to get numberof sql files and match with no of EMS + NMS
#sql=()
#fmefromnms2or (( l=1; l<=count; l++ ))
#do

#echo "l $l"

#sql[$l]=$(echo "$(ls)" | cut -d$'\n' -f$l)

#d
#echo ${sql[@]}

sql=($(ls ))
echo "array : ${sql[@]}"

declare -A IPenms
#declare -A IPDBPair

#Find and tag the DB as nmsdb or tejnmsdb
ec=0 # Count of ems
nc=0 # Count of nms
for sqli in ${sql[@]}
do
echo "sqli : $sqli"
grep 'Database: nmsdb' $sqli

if [[ $? -eq 0 ]]
then
echo "$sqli is NMSDB"
IPenms[$sqli]='nmsdb'
nc=$((nc+1))
else
echo "$sqli is EMSDB"
IPenms[$sqli]='emsdb'
ec=$((ec+1))
fi

done

echo ${IPenms[@]}

echo "nms count : $nc"
echo "ems count : $ec"
#Need to code to validate no of NMSdb = 1 and no of EMS db = no EMSips
#grep 'Database: nmsdb' $sql2
#if [[ $? -eq 0 ]]
#then
#echo "$sql2 is NMSDB"
#else
#echo "$sql2 is EMSDB"
#fi
#Need to have EMS distinct validation


if [[ $nc -eq 0 ]]
then
echo "NMS DB not present.Exiting..."
echo "exit 1"
elif [[ $nc -ge 2 ]]
then
echo "More than one NMS DB found. Exiting..."
echo "exit 1"
elif [[ $1 -ne $ec ]]
then
echo "No of EMSs chosen doesnt match the EMS DBs present.Exiting..."
echo "exit 1"
fi
p=1
Enar=() #This array will contain all the EMS names extract from given EMS dbs 
for o in ${!IPenms[@]} #Here o is the .sql file names
do

echo "key  : $o and value : ${IPenms[$o]}"
  if [[ ${IPenms[$o]} = 'nmsdb' ]]
  then  
        mv $o nmsdb.sql
        o='nmsdb.sql'
	IPDBPair[$o]=${IPAR[0]} #Pair NMS IP to NMS DB file
        NmsDbems=$(grep 'INSERT INTO `EMS` VALUES' $o) #NmsDbems contains the sql contents of EMS extracted from NMS DB
	echo "IP: ${IPDBPair[$o]}"
  elif [[ ${IPenms[$o]} = 'emsdb' ]]
  then
        IPDBPair[$o]=${IPAR[$p]}
        p=$((p+1))
	echo "p: $p"
	echo "IP: ${IPDBPair[$o]}"
	ename=$(grep 'INSERT INTO `TOR` VALUES' $o |rev | cut -d\' -f2 | rev)
	Enar=("${Enar[@]}" $ename)
   fi

echo "EMS array: ${Enar[@]}"

done
#for i in "${!IPDBPair[@]}"
#do
 # echo "key  : $i"
 # echo "value: ${IPDBPair[$i]}"
#done  	

#Extract EMS names from DBs present into an array

#echo "${ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '
#Check uniqueness of array
ty=$(echo "${Enar[@]}" | wc -w)
tx=$(echo "${Enar[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ' | wc -w)

if [[ $ty -eq $tx ]]
then
echo "No duplicate EMSs"
else
echo "Duplicate EMS DBs present"
echo "exit 1"
fi

res="${NmsDbems//[^)]}"
echo "no of ) ${#res}"

Emsnamefromnms3=() #This array will contain all the EMS names extracted from NMS DB

for (( u=1; u<=${#res}; u++ ))
do
echo "u: $u"
Emsnamefromnms=$(echo "$NmsDbems" | cut -d')' -f$u)
Emsnamefromnms2=$(echo "$Emsnamefromnms" | cut -d\' -f2)
echo $Emsnamefromnms2
Emsnamefromnms3=("${Emsnamefromnms3[@]}" $Emsnamefromnms2)
echo ${Emsnamefromnms3[@]}

done

#Check that the EMS names extracted from each EMS DB is present in NMS DB given

for word in ${Enar[@]}
do
found=0
for value in ${Emsnamefromnms3[@]}
do
 if [[ $word = $value ]]
 then
 echo "EMS $word is present in NMS DB"
 found=1
 fi
done

if [[ $found -eq 0 ]]
then
 echo "EMS $word is not present in NMS DB"
 echo "exit 1"
fi
done

cd ..
}
