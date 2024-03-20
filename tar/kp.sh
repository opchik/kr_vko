#!/bin/bash

kill_list=`ps -eF | grep kp.sh | tr -s [:blank:] | cut -d ' ' -f 2 2>/dev/null` 2>/dev/null
stupid_count=0

for kill_var in $kill_list
do
	let stupid_count=$stupid_count+1
done

if [[ $stupid_count -gt 3 ]]
then
	echo "запуск не разрешен, скрипт уже выполяется"
	exit
fi

rm ./kp_log 2>/dev/null
mkdir ./messages/ 2>/dev/null

systems[1+$((1-1))*5]="РЛС 1"
systems[2+$((1-1))*5]="./messages/rls1_kplog"
systems[3+$((1-1))*5]="./messages/rls1_alive"
systems[4+$((1-1))*5]=0 # система работает == 1 / система не работает == 0

systems[1+$((2-1))*5]="РЛС 2"
systems[2+$((2-1))*5]="./messages/rls2_kplog"
systems[3+$((2-1))*5]="./messages/rls2_alive"
systems[4+$((2-1))*5]=0

systems[1+$((3-1))*5]="РЛС 3"
systems[2+$((3-1))*5]="./messages/rls3_kplog"
systems[3+$((3-1))*5]="./messages/rls3_alive"
systems[4+$((3-1))*5]=0

systems[1+$((4-1))*5]="СПРО"
systems[2+$((4-1))*5]="./messages/spro_kplog"
systems[3+$((4-1))*5]="./messages/spro_alive"
systems[4+$((4-1))*5]=0

systems[1+$((5-1))*5]="ЗРДН 1"
systems[2+$((5-1))*5]="./messages/zrdn1_kplog"
systems[3+$((5-1))*5]="./messages/zrdn1_alive"
systems[4+$((5-1))*5]=0

systems[1+$((6-1))*5]="ЗРДН 2"
systems[2+$((6-1))*5]="./messages/zrdn2_kplog"
systems[3+$((6-1))*5]="./messages/zrdn2_alive"
systems[4+$((6-1))*5]=0

systems[1+$((7-1))*5]="ЗРДН 3"
systems[2+$((7-1))*5]="./messages/zrdn3_kplog"
systems[3+$((7-1))*5]="./messages/zrdn3_alive"
systems[4+$((7-1))*5]=0

idx_max=7;

actions[0]=" обнаружила цель "
actions[1]=" произвела выстрел по цели "
actions[2]=" не может стрелять по цели "
actions[3]=" цель движется в зону СПРО "
actions[4]=" поразила цель "
actions[5]=" промахнулась при стрельбе по цели "



echo "Запуск в `date +%d.%m\ %T`" >> ./kp_log 2>/dev/null

#./kp_check &
#pid=$!

iter=0

while :
do
	for ((idx=1; idx<=idx_max; idx++))
	do
		checkthis=$(($iter%50))
		if [[ $checkthis -eq 0 ]]
		then
			rm ${systems[3+$((idx-1))*5]} 2>/dev/null
			fileNotRemoved=$?
			
			#echo "файл не удален: 0, если удален, а 1, если не удален; а он = "$fileNotRemoved
			#echo "что мы думаем что с ней батл по факта = "${systems[4+$((idx-1))*5]}
			
				# ожила             и              была мертва
			if [[ $fileNotRemoved -eq 0 && systems[4+$((idx-1))*5] -eq 0 ]]
			then
				echo ${systems[1+$((idx-1))*5]} " работает исправно" >> ./kp_log 2>/dev/null
				systems[4+$((idx-1))*5]=1
			else
			
				# умерла             и              была жива
				if [[ $fileNotRemoved -eq 1 && systems[4+$(($idx-1))*5] -eq 1 ]]
				then
					echo ${systems[1+$((idx-1))*5]} " не работает" >> ./kp_log 2>/dev/null
					systems[4+$((idx-1))*5]=0
				fi
			fi
		fi
		
		list=`cat ${systems[2+$((idx-1))*5]} 2>/dev/null`
		# если в этот момент запишется новое сообщение, то мы его потеряем. фактически, тут проходят микросекунды, получается почтиневозможное событие
		rm ${systems[2+$((idx-1))*5]} 2>/dev/null
		#cat ${systems[2+$((idx-1))*5]} 2>/dev/null
		
		for message in $list
		do
			timestamp=`echo $message | cut -d : -f 1`
			id=`echo $message | cut -d : -f 2`
			x=`echo $message | cut -d : -f 3`
			y=`echo $message | cut -d : -f 4`
			action=`echo $message | cut -d : -f 5` # 0 stands for detection, 1 stands for firing, 2 stands for lack of ammo
			ammo=`echo $message | cut -d : -f 6` # ammo
			
			time=`date -d @$timestamp`
			
			#echo "tstmp="$timestamp
			#echo "time="$time
			#echo "act="$action
			#echo "actful="${actions[$action]}
			
			if [[ "$ammo" -eq "-1" ]]
			then
				echo $time" "${systems[1+$((idx-1))*5]}${actions[$action]}"id = "$id" c координатами x = "$x" y = "$y >> ./kp_log 2>/dev/null
			else
				echo $time" "${systems[1+$((idx-1))*5]}${actions[$action]}"id = "$id" c координатами x = "$x" y = "$y" Осталось снарядов = "$ammo >> ./kp_log 2>/dev/null
			fi
		done
		
		
		
		iter=$(($iter+1))
		#echo $iter
	done
	
	sleep 0.1
done
