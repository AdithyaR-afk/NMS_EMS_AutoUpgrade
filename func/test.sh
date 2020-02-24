. ./Hotip.sh
declare -A VirIPlist
declare -A IPprio
declare -A Mainmap
declare -A Mainarr
IPfromstring=()
Colist=()
hotstr=''

fHotip "192.168.3.24 192.168.3.25 192.168.3.26 192.168.3.252 192.168.228.14 192.168.228.13 192.168.228.12 192.168.228.252" "EMShot"

for u in ${!Mainmap[@]}
do

	echo "keyL $u and value ${Mainmap[$u]}"
done

echo "Virips list: ${VirIPlist[@]}"
