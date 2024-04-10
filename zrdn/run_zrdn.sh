#!/bin/bash

zrdn1="zrdn1"
zrdn2="zrdn2"
zrdn3="zrdn3"
file_to_run="zrdn/zrdn.sh"
config_file="zrdn/config.yaml"
file_log="messages/message_zrdn"
rm $file_log 2>/dev/null
echo "" > $file_log 2>dev/null

# запуск зрдн
bash "$file_to_run" "$config_file" "$zrdn1" "$file_log" &
bash "$file_to_run" "$config_file" "$zrdn2" "$file_log" &
bash "$file_to_run" "$config_file" "$zrdn3" "$file_log" &

# завершение дочерних процессов
parent_pid=$$
cleanup() {
pkill -P $parent_pid
}
trap cleanup EXIT
wait