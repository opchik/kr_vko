#!/bin/bash

config_file=$1
rls_num=$2
delim=":"


if [ -f "$config_file" ]; then
    x0=$(grep -E "$rls_num$delim" "$config_file" -A 5 | grep 'x0:' | awk '{print $2}')
    y0=$(grep -E "$rls_num$delim" "$config_file" -A 5 | grep 'y0:' | awk '{print $2}')
    az=$(grep -E "$rls_num$delim" "$config_file" -A 5 | grep 'az:' | awk '{print $2}')
    ph=$(grep -E "$rls_num$delim" "$config_file" -A 5 | grep 'ph:' | awk '{print $2}')
    d=$(grep -E "$rls_num$delim" "$config_file" -A 5 | grep 'd:' | awk '{print $2}')

    echo "  x0: $x0"
    echo "  y0: $y0"
    echo "  az: $az"
    echo "  ph: $ph"
    echo "  d: $d"
    echo ""

else
    echo "Файл $config_file не найден."
    exit 1
fi

rm ./rls1_id 2>/dev/null
rm ./rls2_id 2>/dev/null
rm ./rls3_id 2>/dev/null
rm ./rls1_log 2>/dev/null
rm ./rls2_log 2>/dev/null
rm ./rls3_log 2>/dev/null


function InSproDirection()
{
    local Xtarget=$1
    local Ytarget=$2
    local VXtarget=$3
    local VYtarget=$4
    local file_log=$5

    local Rpsro=1200000 
    local Xspro=9500000
    local Yspro=3000000
    
    let xdir=-1*$Xtarget+$Xspro
    let ydir=-1*$Ytarget+$Yspro
    
    local phi=$(echo | awk " { x=atan2($ydir,$xdir)*180/3.141592653589; print x}")
    phi=(${phi/\,*})
    
    local phiV=$(echo | awk " { x=atan2($VYtarget,$VXtarget)*180/3.141592653589; print x}")
    phiV=(${phiV/\,*})
        
    if [[ "$phi" -lt "0" ]]
    then
        let phi=360+$phi
    fi

    if [[ "$phiV" -lt "0" ]]
    then
        let phiV=360+$phiV
    fi  
    
    let dist2=$xdir*$xdir+$ydir*$ydir
    
    echo $dist2 >> ./rls1_fulllog 2>/dev/null
    
    # some magic trigonometry constructions
    theta=$(echo | awk " { x=$Rpsro/sqrt($dist2); y=atan2(x, sqrt(1-x*x))*180/3.141592653589; print y}")
    echo "thinking of theta before trunc= "$theta >> "./$file_log" 2>/dev/null
    theta=(${theta/\,*})
    echo "thinking of theta after trunc= "$theta >> "./$file_log" 2>/dev/null
    
    if [[ "$theta" = "-nan" ]]
    then
        echo "found tasty ananas" >> "./$file_log" 2>/dev/null
        theta=180
    fi
    
    let thetaMin=$phi-$theta
    let thetaMax=$phi+$theta
    
    echo "thetamax = "$thetaMin >> "./$file_log" 2>/dev/null
    echo "thetamin = "$thetaMax >> "./$file_log" 2>/dev/null
    
    check360=0
    check0=0
    if [[ "$thetaMax" -gt "360" ]]
    then
        check360=1
    fi

    if [[ "$thetaMin" -lt "0" ]]
    then
        check0=1
    fi
    
    echo $check360 >> "./$file_log" 2>/dev/null
    echo $check0 >> "./$file_log" 2>/dev/null
    
    if [[ $check360 -eq 0 && $check0 -eq 0 ]]
    then

        if [[ $phiV -gt $thetaMin && $phiV -lt $thetaMax ]]
        then
        
            echo "target in normal sector" >> "./$file_log" 2>/dev/null
        
            echo "targetInSproDir = true" >> "./$file_log" 2>/dev/null
            echo $phi >> "./$file_log" 2>/dev/null
            echo $phiV >> "./$file_log" 2>/dev/null
            return 1
        else
            echo "targetInSproDir = false" >> "./$file_log" 2>/dev/null
            echo $phi >> "./$file_log" 2>/dev/null
            echo $phiV >> "./$file_log" 2>/dev/null
            return 0
        fi
    else
        if [[ $check360 -eq 1 && $check0 -eq 0 ]]
        then
        
            echo "target in normal 360+sect" >> "./$file_log" 2>/dev/null
        
            let thetaMax360=$thetaMax-360
            echo $thetaMax360 >> "./$file_log" 2>/dev/null
            if [[ $phiV -gt $thetaMin || $phiV -lt $thetaMax360 ]]
            then
                echo "targetInSproDir = true" >> "./$file_log" 2>/dev/null
                echo "phi = "$phi >> "./$file_log" 2>/dev/null
                echo "phiV = "$phiV >> "./$file_log" 2>/dev/null
                echo "thetaMax360 = "$thetaMax360 >> "./$file_log" 2>/dev/null
                return 1
            else
                echo "targetInSproDir = true" >> "./$file_log" 2>/dev/null
                echo "phi = "$phi >> "./$file_log" 2>/dev/null
                echo "phiV = "$phiV >> "./$file_log" 2>/dev/null
                echo "thetaMax360 = "$thetaMax360 >> "./$file_log" 2>/dev/null
                return 0
            fi
        
        else
            if [[ $check360 -eq 0 && $check0 -eq 1 ]]
            then
            
                echo "target in normal 0-sect" >> "./$file_log" 2>/dev/null
            
                let thetaMin0=360+$thetaMin
                echo $thetaMin0 >> "./$file_log" 2>/dev/null
                if [[ $phiV -gt $thetaMin0 || $phiV -lt $thetaMax ]]
                then
                    echo "targetInSproDir = true" >> "./$file_log" 2>/dev/null
                    echo "phi = "$phi >> "./$file_log" 2>/dev/null
                    echo "phiV = "$phiV >> "./$file_log" 2>/dev/null
                    echo "phiMin0 = "$thetaMin0 >> "./$file_log" 2>/dev/null
                    return 1
                else
                    echo "targetInSproDir = true" >> "./$file_log" 2>/dev/null
                    echo "phi = "$phi >> "./$file_log" 2>/dev/null
                    echo "phiV = "$phiV >> "./$file_log" 2>/dev/null
                    echo "phiMin0 = "$thetaMin0 >> "./$file_log" 2>/dev/null
                    return 0
                fi
            fi
        fi
    fi
        
}


function InRlsZone()
{
    local X=$1
    local Y=$2
    local X0=$3
    local Y0=$4
    local R=$5
    local AZ=$6
    local PH=$7
    local file_log=$8

    let dx=$X-$X0
    let dy=$Y-$Y0
    
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
            
        echo "angle = $phi" >> "./$file_log" 2>/dev/null
        echo "id = "$id >> "./$file_log" 2>/dev/null
        echo "phimax = "$phiMax >> "./$file_log" 2>/dev/null
        echo "phimin = "$phiMin >> "./$file_log" 2>/dev/null
        echo "" >> "./$file_log" 2>/dev/null

        check_phiMax=$(echo "$phi <= $phiMax"| bc)
        check_phiMin=$(echo "$phi >= $phiMin"| bc)
        if (( $check_phiMax == 1 )) && (( $check_phiMin == 1 ))
        then
            return 1
        fi
    fi

    return 0
}

unique_id=0
deadflag=0
targets_dir=/tmp/GenTargets/Targets/
iter=0
log="_log"
log_id="_id"
file_log="$rls_num$log"
file_id="$rls_num$log_id"
message_path="../messages/messages_"
message_rls="$message_path$rls_num"

while :
do
    touch "../messages/${rls_num}_alive" 2>/dev/null
    
    for ((idx=1; idx<=30; idx++))
    do
        targets[5+$((idx-1))*10]=0
    done
    
    unfound_count=0
    current_counter=1
    
    for file in `ls $targets_dir -t 2>/dev/null | head -30`
    do
        x=`cat $targets_dir$file | tr -d 'X''Y' | tr ',' ':' | cut -d : -f1 2>/dev/null`
        y=`cat $targets_dir$file | tr -d 'X''Y' | tr ',' ':' | cut -d : -f2 2>/dev/null`
        id=${file:12:6}
        
        targetInZone=0
        
        InRlsZone $x $y $x0 $y0 $d $az $ph $file_log
        targetInZone=$?     
        
        if [[ $targetInZone -eq 1 ]]
        then
            
            if [[ $iter -ge 1 ]]
            then
                found=0 # еще не нашли эту цель
                for ((idx=1; idx<=30; idx++))
                do
                    
                    if [[ $deadflag -eq 1 ]]
                    then
                        echo "checkid = "$id >> "./$file_log" 2>/dev/null
                        echo "thisid = "${targets[0+$((idx-1))*10]} >> "./$file_log" 2>/dev/null
                        echo "isalive = "${targets[5+$((idx-1))*10]} >> "./$file_log" 2>/dev/null
                        echo "isreported = "${targets[6+$((idx-1))*10]} >> "./$file_log" 2>/dev/null

                    fi
                                    
                    if [[ "${targets[0+$((idx-1))*10]}" == "$id" ]]
                    then
        
                        found=1
                        
                        if [[ ${targets[5+$((idx-1))*10]} -eq 0 ]]
                        then
                        
                            #found=1
                            oldx=${targets[1+$((idx-1))*10]}
                            oldy=${targets[2+$((idx-1))*10]}
                            targets[1+$((idx-1))*10]=$x
                            targets[2+$((idx-1))*10]=$y                         
                            let vx=x-oldx
                            let vy=y-oldy
                                        
                            if [[ "$vx" != "0" ]]
                            then
                                targets[3+$((idx-1))*10]=$vx
                            fi
                            
                            if [[ "$vy" != "0" ]]
                            then
                                targets[4+$((idx-1))*10]=$vy
                            fi
                            
                            let v2=vx*vx+vy*vy
                                                            
                            #alive flag
                            targets[5+$((idx-1))*10]=1;
                                            
                            # if target is alive and we have not reported КП о нет, то сообщаем
                            if [[ ${targets[5+$((idx-1))*10]} -eq 1 && ${targets[6+$((idx-1))*10]} -eq 0 && "$v2" != 0 ]]
                            then
                                echo "Обнаружена цель с ID = "$id" с координатами "$x" и "$y" и скоростями "$vx" и "$vy >> $message_rls 2>/dev/null
                                echo "`date +%s`:$id:$x:$y:0:-1" >> $message_rls 2>/dev/null
                                targets[6+$((idx-1))*10]=1;
                                                                    
                                if [[ v2 -ge 64000000 && v2 -le 100000000 ]]
                                then
                                
                                    # это ББ от БР
                                    InSproDirection $x $y $vx $vy $file_log
                                    targetInSproDir=$?
                                    
                                    # это ББ от БР летит к СПРО
                                    echo "id = "$id >> "./$file_log" 2>/dev/null
                                    echo "targetInSproDir = "$targetInSproDir >> "./$file_log" 2>/dev/null
                                    if [[ $targetInSproDir -eq 1 ]]
                                    then
                                        echo "Цель ID = "$id" движется в зону действия СПРО" >> $message_rls 2>/dev/null
                                        echo "`date +%s`:$id:$x:$y:3:-1" >> $message_rls 2>/dev/null
                                    fi
                                    
                                fi
                            fi
                        fi
                        
                        break
                    fi
                
                done
                
                # после цикла по всем имеющимся целями так и не нашли новую цель
                if [[ $found -eq 0 ]]
                then
                    deadflag=1
                    unfound[0+$((unfound_count))*3]=$id;
                    unfound[1+$((unfound_count))*3]=$x;
                    unfound[2+$((unfound_count))*3]=$y;
                    
                    # увеличиваем счетчик новых целей
                    $((unfound_count++)) 2>/dev/null
                fi
        
            fi
                                
            if [[ $iter -eq 0 ]]
            then
                targets[0+$((current_counter-1))*10]=$id;
                targets[1+$((current_counter-1))*10]=$x;
                targets[2+$((current_counter-1))*10]=$y;
                targets[3+$((current_counter-1))*10]=$vx;
                targets[4+$((current_counter-1))*10]=$vy;
                targets[5+$((current_counter-1))*10]=0; # флаг актуальности цели
                targets[6+$((current_counter-1))*10]=0; # флаг выдачи данных на КП
            fi

            $((unique_id++)) 2>/dev/null
            echo "$unique_id:$id" >> "./$file_id"
                
            $((current_counter++)) 2>/dev/null
        fi

    done
    deadflag=0
    
    echo "unfound count = "$unfound_count >> "./$file_log" 2>/dev/null
    
    # после полной итерации считывания целей обрабатываем новые цели    
    for ((thiscount=1; thiscount<=unfound_count; thiscount++))
    do
        echo "unfound id# "$thiscount" = "${unfound[0+$((thiscount-1))*3]} >> "./$file_log" 2>/dev/null
        # берем новую цель и записываем ее на место мертвой в массиве
        for ((idx=1; idx<=30; idx++))
        do
        
            if [[ ${targets[5+$((idx-1))*10]} -eq 0 && $iter -gt 1 ]]
            then
                
                targets[0+$((idx-1))*10]=${unfound[0+$((thiscount-1))*3]}
                targets[1+$((idx-1))*10]=${unfound[1+$((thiscount-1))*3]}
                targets[2+$((idx-1))*10]=${unfound[2+$((thiscount-1))*3]}
                targets[5+$((idx-1))*10]=1
                targets[6+$((idx-1))*10]=0
            fi
                    
        done
    
    done
    
    echo $iter >> "./$file_id"
    $((iter++)) 2>/dev/null
        
    sleep 0.5

    echo "___" >> "./$file_log" 2>/dev/null
    echo "" >> "./$file_log" 2>/dev/null
    echo "NEW ITER"$iter >> "./$file_log" 2>/dev/null
    echo "___" >> "./$file_log" 2>/dev/null
    echo "" >> "./$file_log" 2>/dev/null

done
