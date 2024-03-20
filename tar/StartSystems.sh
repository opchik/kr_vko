#!/bin/bash

./StopSystems.sh 1>/dev/null


echo "Запуск генератора целей..."
sleep 2

./GenTargets.sh 1>/dev/null &
GTpid=$!
echo "Запущен генератор целей с pid = "$GTpid
sleep 0.5

cd ./systems/rls/
./rls1.sh &
RLS1pid=$!
echo "Запущена РЛС 1 c pid = "$RLS1pid
sleep 0.5

./rls2.sh &
RLS2pid=$!
echo "Запущена РЛС 2 c pid = "$RLS2pid
sleep 0.5

./rls3.sh &
RLS3pid=$!
echo "Запущена РЛС 3 c pid = "$RLS3pid
sleep 0.5

cd ../spro/
./spro.sh &
SPROpid=$!
echo "Запущена СПРО c pid = "$SPROpid
sleep 0.5

cd ../zrdn/
./zrdn1.sh &
ZRDN1pid=$!
echo "Запущен ЗРДН 1 c pid = "$ZRDN1pid
sleep 0.5

./zrdn2.sh &
ZRDN2pid=$!
echo "Запущен ЗРДН 2 c pid = "$ZRDN2pid
sleep 0.5

./zrdn3.sh &
ZRDN3pid=$!
echo "Запущен ЗРДН 3 c pid = "$ZRDN3pid
sleep 0.5

cd ../../
./kp.sh &
KPpid=$!
echo "Запущен КП с pid = "$KPpid
sleep 0.5


echo "Для остановки всех систем воспользуйтесь ./StopSystems.sh"
sleep 0.5



