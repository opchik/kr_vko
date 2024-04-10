#!/bin/bash

config_file=$1
rls_num=$2
file_log=$3
delim=":"
targets_dir="/tmp/GenTargets/Targets/"



if [ -f "$config_file" ]; then
    x0=$(grep -E "$rls_num$delim" "$config_file" -A 5 | grep 'x0:' | awk '{print $2}')
    y0=$(grep -E "$rls_num$delim" "$config_file" -A 5 | grep 'y0:' | awk '{print $2}')
    az=$(grep -E "$rls_num$delim" "$config_file" -A 5 | grep 'az:' | awk '{print $2}')
    ph=$(grep -E "$rls_num$delim" "$config_file" -A 5 | grep 'ph:' | awk '{print $2}')
    d=$(grep -E "$rls_num$delim" "$config_file" -A 5 | grep 'd:' | awk '{print $2}')
else
    echo "Файл $config_file не найден."
    exit 1
fi



function InRlsZone()
{
    local dx=$1
    local dy=$2
    local R=$3
    local AZ=$4
    local PH=$5

    local r=$(echo "sqrt ( (($dx*$dx+$dy*$dy)) )" | bc -l)
    r=${r/\.*}

    if (( $r <= $R ))
    then
        local phi=$(echo | awk " { x=atan2($dy,$dx)*180/3.14; print x}")
        phi=(${phi/\,*})
        check_phi=$(echo "$phi < 0"| bc)
        if [[ "$check_phi" -eq 1 ]]
        then
            phi=$(echo "360 + $phi" | bc)
        fi
        let phiMax=$AZ+PH/2
        let phiMin=$AZ-PH/2

        check_phiMax=$(echo "$phi <= $phiMax"| bc)
        check_phiMin=$(echo "$phi >= $phiMin"| bc)
        if (( $check_phiMax == 1 )) && (( $check_phiMin == 1 ))
        then
            return 1
        fi
    fi
}


function Speedometer()
{
    local v=$1
    if [[ $v>=8000  && $v<=10000 ]]
    then
        return 1
    fi
    return 0
}

function ToSproDirrection()
{
    local v=$1
    local R=$2

    if [[ $b<= $R ]]
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

        # проверка наличия цели в области видимости рлс
        targetInZone=0
        InZrdnZone $dx $dy $r $az $ph
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
                v=$(echo "sqrt ( (($vx*$vx+$vy*$vy)) )" | bc -l)

                # проверка, что цель - БР
                Speedometer $v
                SpeedometerResult=$?
                if [[ $SpeedometerResult -eq 1 ]]
                then
                    # проверка, что цель летит в сторону спро
                    ToSproDirrection $v 
                    ToSproDirrectionResult=$?
                    if [[ $ToSproDirrectionResult -eq 1 ]]
                    then
                        echo "Обнаружена цель $id"
                    fi
                fi
            fi
        fi
    done

    sleep 0.5
done