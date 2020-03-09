declare -A Localarr
allarr=$@

#echo ${allarr[@]}

for ty in ${allarr[@]}
do
        yu=$(echo $ty | cut -d'=' -f2)
        jo=$(echo $ty | cut -d'=' -f1)
        Localarr[$jo]=$yu
done

for ui in ${!Localarr[@]}
do
        echo "$ui : ${Localarr[$ui]}"
done

