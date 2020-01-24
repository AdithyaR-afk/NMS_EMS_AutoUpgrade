path=$(echo `pwd`)
. /$path/DownBuild.sh

echo 'Enter no of IPS'
read IPno

Iar=()
for (( k=0; k<$IPno; k++ ))
do

echo "Enter IP $((k + 1))  "
read Iar[k]

done

echo ${Iar[@]}

echo 'Enter To Build Ex: 7_5_0_a15_1'



read tobld

while [[ 1  ]]
do

secd=$(echo $tobld | cut -d'a' -f 2)
firs=$(echo $tobld | cut -d'a' -f 1)
firs=${firs::-1}
echo $firs

cont=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/~checkout~/ReleaseNotes/NMSreleases/REL_$firs/a_x/rn_ax.html#Releases)


echo $cont | grep $tobld

if [[ $? -ne 0 ]]
then

echo 'Error : No such build. Re-enter build'
read tobld

else
echo 'Build found'
break
fi
done

NMSL=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/NMSreleases/REL_$firs/a_x/a$secd/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'build/NMS_Rel')
echo $NMSL

#Get EMS Release
EMSL=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/EMSreleases/REL_$firs/a_x/a$secd/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'builds/EMS_Rel')
echo $EMSL

#Get Install_all.sh

InstallL=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/EMSreleases/REL_$firs/a_x/a$secd/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'builds/install')
echo $InstallL

#Get Dependent Software link

DependL=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/EMSreleases/REL_$firs/a_x/a$secd/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'builds/Dependent')
echo $DependL

#Check if Build directories are present in given IPs in /home/ems location

Eln=${#Iar[@]}


echo "ELen : $Eln"

for (( y=0; x<$Eln; y++ ))
do
echo "Passing :  $y"
DBuild $y &
done

wait

echo "Download Complete!"

