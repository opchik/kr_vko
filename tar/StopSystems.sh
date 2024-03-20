#!/bin/bash

massive[0]="GenTargets"
massive[1]="rls1"
massive[2]="rls2"
massive[3]="rls3"
massive[4]="spro"
massive[5]="zrdn1"
massive[6]="zrdn2"
massive[7]="zrdn3"
massive[8]="kp"

size=8

for ((idx=0; idx<=size; idx++))
do

	kill_list=`ps -eF | grep ${massive[$idx]} | tr -s [:blank:] | cut -d ' ' -f 2 2>/dev/null` 2>/dev/null
	kill_sum=0
	for kill_var in $kill_list
	do
		kill $kill_var	2>/dev/null
		let kill_sum=kill_sum+1-$?
	done

	# т.к. grep сам умирает после своего выполнения, его kill всегда возвращает 1
	if [[ $kill_sum -gt 0 ]]
	then
		echo "${massive[$idx]}.sh остановлен"
	else
		echo "${massive[$idx]}.sh не остановлен или не был запущен"
	fi

	sleep 0.5
	
done

sleep 3
exit
