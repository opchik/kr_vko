#!/bin/bash

# запуск генератора целей
./GenTargets.sh &
sleep 0.5

# # запуск рлс
# ./rls/run_rls.sh &

# запуск зрдн
./zrdn/run_zrdn.sh  &


# завершение дочерних процессов
parent_pid=$$
cleanup() {
  pkill -P $parent_pid
}
trap cleanup EXIT
wait