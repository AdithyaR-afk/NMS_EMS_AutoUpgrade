function fSerStop #Argument to this function is a single IP
{
sshpass -f fsshpass ssh -o stricthostkeychecking=no root@$1 "service nms stop &"
sshpass -f fsshpass ssh -o stricthostkeychecking=no root@$1 "service ems stop &"
sleep 10
}
