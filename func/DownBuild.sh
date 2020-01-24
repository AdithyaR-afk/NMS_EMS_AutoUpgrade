function DBuild #Should take arguments as first ip, then build tag
{
ix=$1
build=$2
echo "$ix" 
bflag=0 #Check if complete build present or not

sec=$(echo $build | cut -d'a' -f 2)
fir=$(echo $build | cut -d'a' -f 1)
fir=${fir::-1}

NMSLink=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/NMSreleases/REL_$fir/a_x/a$sec/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'build/NMS_Rel')
echo $NMSLink

EMSLink=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/EMSreleases/REL_$fir/a_x/a$sec/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'builds/EMS_Rel')
echo $EMSLink

#Get Install_all.sh

InstallLink=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/EMSreleases/REL_$fir/a_x/a$sec/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'builds/install')
echo $InstallLink

#Get Dependent Software link

DependLink=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/EMSreleases/REL_$fir/a_x/a$sec/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'builds/Dependent')
echo $DependLink

if [ sshpass -f fsshpass ssh root@$ix "[ -d /home/ems/$build ]" ] && [ $build != '' ]
then
echo 'build directory exists'


sshpass -f fsshpass ssh root@$ix "test -f  /home/ems/$build/EMS* -a -f /home/ems/$build/Dep* -a -f /home/ems/$build/inst* -a -f /home/ems/$build/NMS*"

if [[ $? -ne 0 ]]
then
bflag=1
fi

else
echo 'build directory not present'
sshpass -f fsshpass ssh root@$ix "mkdir /home/ems/$build"
bflag=1
fi

if [[ $bflag -eq 1 ]]
then



sshpass -f fsshpass scp -r $path/conf_file root@$ix:/home/ems

sshpass -f fsshpass ssh root@$ix << EOF
cd /home/ems/$build
curl -L -K /home/ems/conf_file -O $InstallLink &
curl -L -K /home/ems/conf_file -O $NMSLink &
curl -L -K /home/ems/conf_file -O $EMSLink &
curl -L -K /home/ems/conf_file -O $DependLink &
wait
chmod a+x install_all.sh
EOF

fi
}
