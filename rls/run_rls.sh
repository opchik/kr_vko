#!/bin/bash

rls1="rls1"
rls2="rls2"
rls3="rls3"
file_to_run="./rls/rls.sh"
config_file="./rls/config.yaml"
file_log="messages/message_zrdn"
rm $file_log 2>/dev/null
echo "" > $file_log 2>/dev/null


# запуск рлс
bash "$file_to_run" "$config_file" "$rls1" "$file_log" &
bash "$file_to_run" "$config_file" "$rls2" "$file_log" &
bash "$file_to_run" "$config_file" "$rls3" "$file_log" &

# завершение дочерних процессов
parent_pid=$$
cleanup() {
  pkill -P $parent_pid
}
trap cleanup EXIT
wait