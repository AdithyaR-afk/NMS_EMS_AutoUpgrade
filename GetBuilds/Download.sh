path=$(echo `pwd`)
. $path/DownBuild.sh

echo $path

echo 'Enter no of IPS'
read IPno

IPAR=()
for (( k=0; k<$IPno; k++ ))
do

echo "Enter IP $((k + 1))  "
read IPAR[k]

done

echo ${IPAR[@]}

echo 'Enter To Build Ex: 7_5_0_a15_1'
read tobuild


while [[ 1  ]]
do

sec=$(echo $tobuild | cut -d'a' -f 2)
fir=$(echo $tobuild | cut -d'a' -f 1)
fir=${fir::-1}
echo $fir

content=$(curl -L -K $path/conf_file http://tn100build/cgi-bin/cvsweb.nms/~checkout~/ReleaseNotes/NMSreleases/REL_$fir/a_x/rn_ax.html#Releases)


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

echo "ELen : $Elen"

echo 'Downloading Builds on specified servers.Please wait....'

for (( x=0; x<$Elen; x++ ))
do
#echo "Passing :  $x"
DBuild $x &
done

wait

echo "Download Complete!"

