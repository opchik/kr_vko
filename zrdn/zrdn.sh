#!/bin/bash

config_file=$1
zrdn_num=$2
file_log=$3
delim=":"
ammo=20
targets_dir="/tmp/GenTargets/Targets/"



if [ -f "$config_file" ]; then
	x0=$(grep -E "$zrdn_num$delim" "$config_file" -A 5 | grep 'x0:' | awk '{print $2}')
	y0=$(grep -E "$zrdn_num$delim" "$config_file" -A 5 | grep 'y0:' | awk '{print $2}')
	r=$(grep -E "$zrdn_num$delim" "$config_file" -A 5 | grep 'r:' | awk '{print $2}')

	echo "x0=" $x0
	echo "y0=" $y0
	echo "r=" $r
else
	echo "Файл $config_file не найден."
	exit 1
fi

function InZrdnZone()
{
	local dx=$1
	local dy=$2
	local R=$3

	local r=$(echo "sqrt ( (($dx*$dx+$dy*$dy)) )" | bc -l)
	r=${r/\.*}

	if (( $r <= $R ))
	then
		# local phi=$(echo | awk " { x=atan2($dy,$dx)*180/3.14; print x}")
		# phi=(${phi/\,*})
		# check_phi=$(echo "$phi < 0"| bc)
		# if [[ "$check_phi" -eq 1 ]]
		# then
		# 	phi=$(echo "360 + $phi" | bc)
		# fi
		# let phiMin=0
		# let phiMax=360
		# echo "phi=" $phi
		# echo "phiMin=" $phiMin
		
		# check_phiMax=$(echo "$phi <= $phiMax"| bc)
		# check_phiMin=$(echo "$phi >= $phiMin"| bc)

		# if (( $check_phiMax == 1 )) && (( $check_phiMin == 1 ))
		# then
			return 1
		# fi
	fi
	return 0
}

function Speedometer()
{
	local vx=$1
	local vy=$2

	local v=$(echo "sqrt ( (($vx*$vx+$vy*$vy)) )" | bc -l)
	if [[ $v<=1000 ]]
	then
		return 1
	fi
	return 0
}

function IsDestroyed()
{
	local random_num=$1
	if (( $random_num >= 50 ))
	then
		return 1
	fi 
	return 0
}




while :
do
	for file in `ls $targets_dir -t 2>/dev/null | head -30`
	do
		x=`cat $targets_dir$file | tr -d 'X''Y' | tr ',' ':' | cut -d : -f1 2>/dev/null`
		y=`cat $targets_dir$file | tr -d 'X''Y' | tr ',' ':' | cut -d : -f2 2>/dev/null`
		id=${file:12:6}
		let dx=$x0-$x
		let dy=$y0-$y

		# проверка наличия цели в области зрдн
		targetInZone=0
		InZrdnZone $dx $dy $r
		targetInZone=$?

		if [[ $targetInZone -eq 1 ]]
		then
			# проверка наличия в файле этой цели
			str=$(tail -n 30 $file_log | grep $id | tail -n 1)
			num=$(tail -n 30 $file_log | grep -c $id)
			if [[ $num == 0 ]]
			then
				echo "Обнаружена цель ID: $id"
				echo "$id $x $y" >> $file_log
			else
				x1=$(echo "$str" | awk '{print $2}')
				y1=$(echo "$str" | awk '{print $3}')
				let vx=x-x1
				let vy=y-y1

				# проверка цели для зрдн
				Speedometer $vx $vy
				SpeedometerResult=$?
				if [[ $SpeedometerResult -eq 1 ]]
				then
					# проверка на наличие противоракет
					if [[ $ammo -gt 0 ]]
					then
						# две попытки поразить цель
						for num in 1 2
						do
							let ammo=ammo-1
							random_num=$((1 + $RANDOM % 100))
							IsDestroyed $random_num
							IsDestroyedResult=$?

							# если цель поражена, то второй раз не стреляем
							if [[ $IsDestroyedResult -eq 1 ]]
							then 
								echo "Цель $id поражена"
								echo ""
								break
							fi
						done
					else
						echo "Противоракеты закончились"
						echo ""
					fi 
				fi
			fi
		fi
	done

	sleep 0.5
done