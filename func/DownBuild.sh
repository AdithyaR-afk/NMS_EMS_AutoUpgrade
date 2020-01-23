function DBuild
{
ix=$1
echo "$ix = : ${IPAR[$ix]}"
bflag=0 #Check if complete build present or not



if [ sshpass -f fsshpass ssh root@${IPAR[$ix]} "[ -d /home/ems/$tobuild ]" ] && [ $tobuild != '' ]
then
echo 'build directory exists'


sshpass -f fsshpass ssh root@${IPAR[$ix]} "test -f  /home/ems/$tobuild/EMS* -a -f /home/ems/$tobuild/Dep* -a -f /home/ems/$tobuild/inst* -a -f /home/ems/$tobuild/NMS*"

if [[ $? -ne 0 ]]
then
bflag=1
fi

else
echo 'build directory not present'
sshpass -f fsshpass ssh root@${IPAR[$ix]} "mkdir /home/ems/$tobuild"
bflag=1
fi

if [[ $bflag -eq 1 ]]
then



sshpass -f fsshpass scp -r $path/conf_file root@${IPAR[$ix]}:/home/ems

sshpass -f fsshpass ssh root@${IPAR[$ix]} << EOF
cd /home/ems/$tobuild
curl -L -K /home/ems/conf_file -O $InstallLink &
curl -L -K /home/ems/conf_file -O $NMSLink &
curl -L -K /home/ems/conf_file -O $EMSLink &
curl -L -K /home/ems/conf_file -O $DependLink &
wait
chmod a+x install_all.sh
EOF

fi
}
