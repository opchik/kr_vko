#!/bin/bash

rls1="rls1"
rls2="rls2"
rls3="rls3"
file_to_run="rls.sh"
config_file="config.yaml"

# запуск рлс
bash "$file_to_run" "$config_file" "$rls1" &
bash "$file_to_run" "$config_file" "$rls2" &
bash "$file_to_run" "$config_file" "$rls3" &

# завершение дочерних процессов
parent_pid=$$
cleanup() {
  pkill -P $parent_pid
}
trap cleanup EXIT
wait