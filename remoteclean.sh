function cl
{
sshpass -f fsshpass ssh -o StrictHostKeyChecking=no root@$v  << EOF
        yes | cleanall
        cd /opt/
        rm -rf Ins*
EOF
}



ListIP=()
list=$(echo $1)
echo "list: $list"
spaces=$(echo $list | tr -cd ' \t' | wc -c)
nof=$((spaces+1))
sa=$((nof-1))
echo "Spacecount: $spaces"
unset ListIP
while (( $nof > 0 ))
do
ListIP[$sa]=$(echo $list | cut -d' ' -f$nof)
nof=$((nof-1))
sa=$((sa-1))
done
echo "IParray: ${ListIP[@]}"

for v in "${ListIP[@]}"
do
        echo "Clean $v? (y/n)"
        read act
	if [[ "$act" != 'y' ]]
	then
		echo "Cancelling Clean. Correct your input"
		exit 1
	fi
done

for v in "${ListIP[@]}"
do
		echo "$v"
		cl & 
done

