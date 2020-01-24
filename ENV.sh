path=$(echo `pwd`)
declare -A GenARGAR
export type
export tobuild
export frombuild

#Source all functions here:
. $path/func/DownBuild.sh
. $path/func/ReadDB.sh
. $path/func/SerStop.sh
. $path/func/RemMysql.sh


echo 'Enter Upgrade Name'
read UpgName

echo 'Enter Mode No. : Co-res/Standalone (1/2)'
read mode
export mode

GenARGAR(IMode)=$mode

echo 'Enter no of EMS'
read Eno
echo 'Enter NMS IP'
read NMSIP
Earr=()
for (( i=0; i<$Eno; i++ ))
do

echo "Enter EMS$((i + 1))  IP"
read Earr[i]

done
#echo "${Earr[*]}"

export IPAR=($NMSIP ${Earr[@]})
declare -A IPDBPair
export IPDBPair[@]

echo ${IPAR[@]}


echo 'Is db in current location? (y/n)'
read dbloc

if [[ $dbloc = 'y' ]]
then
loc=`pwd`

else
echo 'Enter full path of db location'
read loc
fi

echo $loc

echo 'Enter To Build Ex: 7_5_0_a15_1'



read tobuild


while [[ 1  ]]
do

sec=$(echo $tobuild | cut -d'a' -f 2)
fir=$(echo $tobuild | cut -d'a' -f 1)
fir=${fir::-1}
echo $fir

content=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/~checkout~/ReleaseNotes/NMSreleases/REL_$fir/a_x/rn_ax.html#Releases)


echo $content | grep $tobuild

if [[ $? -ne 0 ]]
then

echo 'Error : No such build. Re-enter build'
read tobuild

else
echo 'Build found' 
break
fi
done

#http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/NMSreleases/REL_7_5_0/a_x/a15_7_3/builds.html  | grep -Po '(?<=href=")[^"]*'
#Get NMS Release

NMSLink=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/NMSreleases/REL_$fir/a_x/a$sec/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'build/NMS_Rel')
echo $NMSLink

#Get EMS Release
EMSLink=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/EMSreleases/REL_$fir/a_x/a$sec/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'builds/EMS_Rel')
echo $EMSLink

#Get Install_all.sh

InstallLink=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/EMSreleases/REL_$fir/a_x/a$sec/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'builds/install')
echo $InstallLink

#Get Dependent Software link

DependLink=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/EMSreleases/REL_$fir/a_x/a$sec/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'builds/Dependent')
echo $DependLink

#Check if Build directories are present in given IPs in /home/ems location

Elen=${#IPAR[@]}

#for (( ig=0;ig<$Elen;ig++ ))
#for xip in ${IPAR[@]}
#do

#echo "xip : $xip"
#bflag=0 #Check if complete build present or not



#if [ sshpass -p  root@${IPAR[$ig]} "[ -d /home/ems/$tobuild ]" ] && [ $tobuild != '' ]
#then
#echo 'build directory exists'


#sshpass -p  ssh root@${IPAR[$ig]} "test -f  /home/ems/$tobuild/EMS* -a -f /home/ems/$tobuild/Dep* -a -f /home/ems/$tobuild/inst* -a -f /home/ems/$tobuild/NMS*"

#if [[ $? -ne 0 ]]
#then
#bflag=1
#fi

#else
#echo 'build directory not present'
#sshpass -p  ssh root@${IPAR[$ig]} "mkdir /home/ems/$tobuild"
#bflag=1
#fi

#if [[ $bflag -eq 1 ]]
#then



#sshpass -f fsshpass scp -r /home/adithyar/Upgrade/conf_file root@${IPAR[$ig]}:/home/ems

#sshpass -p  ssh root@${IPAR[$ig]} << EOF
#cd /home/ems/$tobuild 
#curl -L -K /home/ems/conf_file -O $InstallLink &
#curl -L -K /home/ems/conf_file -O $NMSLink &
#curl -L -K /home/ems/conf_file -O $EMSLink & 
#curl -L -K /home/ems/conf_file -O $DependLink &
#wait
#chmod a+x install_all.sh
#EOF

#fi
#done
echo "ELen : $Elen"

for (( x=0; x<$Elen; x++ ))
do
echo "Passing :  ${IPAR[$x]} and $tobuild to DBBuild"
DBuild ${IPAR[$x]} $tobuild &
done

wait

echo "Download Complete!"

echo "Checking DB"
echo `pwd`
fReadDB $Eno

for g in ${!IPDBPair[@]}
do

echo "key : $g  & value: ${IPDBPair[$g]}"



sshpass -f fsshpass ssh root@${IPDBPair[$g]} << EOF
rm -rf /home/ems/DBUpgrade
mkdir /home/ems/DBUpgrade
EOF

#Move the correct DBs to the Correct IPs
echo "Transfering DB to remote locations"
sshpass -f fsshpass scp -r $path/DB/$g root@${IPDBPair[$g]}:/home/ems/DBUpgrade/


#Stop services in all IPS
echo "Stopping EMS/NMS in remote locations"
for (( y=0; y<$Elen; y++ ))
do
fSerStop ${IPAR[$y]} &
done
wait
#Stop mysql and uninstall in all IPs
echo "Uninstalling mysql in all servers"
for (( z=0; z<$Elen; z++ ))
do
fRemMysql ${IPAR[$z]} &
done
wait


#Download from Build to install DB server
for (( x=0; x<$Elen; x++ ))
do
echo "Passing :  ${IPAR[$x]} and $frombuild to DBBuild"
DBuild ${IPAR[$x]} $frombuild &
done

wait

