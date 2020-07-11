#********************************************************
# PROGRAM: CPU Scheduling Algorithm Simulation
# CREATED BY: Meg Tuason, Andrea Chung, Alex Filart
# DATE CREATED: 4 May 2019
# DATE MODIFIED: 14 May 2019
# *******************************************************

echo -e "=======================\nWelcome to CPU Scheduler\nVersion 2.00\n======================="

read -p "Input file name: " name

proc=$(cut -d ',' -f 1,2,3,4 $name | sed -e 's/ //')
arr=$(cut -d ',' -f 2 $name | sort -n)
newarr=''
arrange=()

#takes process number input and changes to "Px"
formprocess()
{
	if [[ $1 == *"P"*[0-9] ]]
	then
		pn="P"$(echo $1 | tr -dc '0-9')
		n=$(echo $1 | tr -dc '0-9' | sort -n)
	fi
	newproc=$(echo $pn $2 $3 $4 0 0 | sed -e 's/ /,/g')
	arrange+=($n)
}

#isolate P from process number
getPnumber()
{
	if [[ $1 == *"P"*[0-9] ]]
	then
		pron=$(echo $1 | tr -dc '0-9')
	fi
}

#get arrival time of a process
getArrTime()
{
	at=$2
}

#get priority value of a process
getPrio()
{
	pr=$4
}

#get process burst time
getBurst()
{
	bt=$3
}

#get process turnaround time
getTurnTime()
{
	tt=$6
}

#check if array contains certain value
arr_contains () {
    local array="$1[@]"
    local seeking=$2
    in=0
    for element in "${!array}"; do
        if [[ $element == $seeking ]];
        then
            in=1
            break
        fi
    done
    return $in
}

#https://stackoverflow.com/questions/14366390/check-if-an-element-is-present-in-a-bash-array/14367368

#puts all inputted processes into an array
for i in $proc
do
	split=$(echo $i | sed -e 's/,/ /g')
	formprocess $split
	if [[ $newarr == '' ]]
	then
		newarr=($newproc)
	else
		newarr+=( $newproc )
	fi
done
# https://unix.stackexchange.com/questions/328882/how-to-add-remove-an-element-to-from-the-array-in-bash

# NON-PREEMPTIVE PRIORITY
sortarr=''
sortprio=''
#sort by arrival time
for i in $arr
do
	for j in "${!newarr[@]}"
	do
		pls=${newarr[$j]}
		split=$(echo ${newarr[$j]} | sed -e 's/,/ /g')
		getArrTime $split x
		if [[ $at == $i ]]
		then
			if [[ $sortarr == '' ]]
			then
				sortarr=( $pls )
				break
			else
				arr_contains sortarr $pls
				if [[ $in == 1 ]]
				then
					continue
				else
					sortarr+=( $pls )
					break
				fi
			fi
		fi
	done
done

#function to form final process sequence array for non-preemptive priority
sortonefinal ()
{
	if [[ $sortprio == '' ]]
	then
		waitt=0
		new=$(echo $1 $2 $3 $4 $waitt $3 $waitt $3 | sed -e 's/ /,/g')
		sortprio=( $new )
	else
		qcount=${#sortprio[@]}
		temp=${sortprio[$((qcount - 1))]}
		splittemp=$(echo $temp | sed -e 's/,/ /g')
		getTurnTime $splittemp
		waitt="$((tt - $2))" #WT = TotTime - AT
		turnt="$(($waitt + $3 + $2))" #TT = WT + BT + AT
		new=$(echo $1 $2 $3 $4 $waitt $turnt | sed -e 's/ /,/g')
		sortprio+=( $new )
	fi
}


#sort final non-preemptive priority array sequence

#bubble sort by priority and arrival time
for i in "${!sortarr[@]}"
do
	for j in "${!sortarr[@]}"
	do
		one=${sortarr[$i]}
		two=${sortarr[$((j + 1))]}
		splitone=$(echo $one | sed -e 's/,/ /g')
		splittwo=$(echo $two | sed -e 's/,/ /g')
		getArrTime $splitone
		atone=$at
		getArrTime $splittwo
		attwo=$at
		if [[ $atone == $attwo ]]
		then
			getPrio $splitone
			prone=$pr
			getPrio $splittwo
			prtwo=$pr
			if (( $prone <= $prtwo ))
			then
				break
			else
				sortarr[i]=$two
				sortarr[$((j + 1))]=$one
				break
			fi
		else
			break
		fi
	done
done

#sorts sequence of processes
added=''
for i in "${!sortarr[@]}"
do
	for j in "${!sortarr[@]}"
	do
		current=${sortarr[$i]}
		if [[ $i == 0 ]]
		then
			splitcur=$(echo $current | sed -e 's/,/ /g')
			sortonefinal $splitcur
			break
		else
			temparr=''
			for k in "${!sortarr[@]}"
			do
				hi=${sortarr[$k]}
				arr_contains added $hi
				if [[ $k == 0 ]]
				then
					continue
				elif [[ $in == 1 ]]
					then
						continue
				else
					qcount=${#sortprio[@]}
					temp=${sortprio[$((qcount - 1))]}
					splittemp=$(echo $temp | sed -e 's/,/ /g')
					getTurnTime $splittemp
					check=${sortarr[$k]}
					split=$(echo $check | sed -e 's/,/ /g')
					getArrTime $split
					if (( $tt >= $at ))
					then
						if [[ $temparr == '' ]]
						then
							temparr=($check)
						else
							temparr+=($check)
						fi
					fi
				fi
			done
			if [[ $temparr == '' ]]
			then
				continue
			else

				for x in "${!temparr[@]}"
				do
					for y in "${!temparr[@]}"
					do
						if [[ $x == $(( ${#temparr[@]} - 1 )) ]]
						then
							break
						else
							curone=${temparr[$x]}
							curtwo=${temparr[$((x + 1))]}
							splitcurone=$(echo $curone | sed -e 's/,/ /g')
							splitcurtwo=$(echo $curtwo | sed -e 's/,/ /g')
							getPrio $splitcurone
							prone=$pr
							getPrio $splitcurtwo
							prtwo=$pr
							if (( $prone <= $prtwo ))
							then
								break
							else
								temparr[x]=$curtwo
								temparr[$((x + 1))]=$curone
								break
							fi
						fi
					done
				done
				add=${temparr[0]}
				arr_contains added $add
				if [[ $in == 0 ]]
				then
					splitty=$(echo $add | sed -e 's/,/ /g')
					sortonefinal $splitty
					if [[ $added == '' ]]
					then
						added=($add)
					else
						added+=($add)
					fi
				fi
				break
			fi
		fi
	done
done
#sort by process number
print_copy=()
for i in "${arrange[@]}"
do
	for j in "${!sortprio[@]}"
	do
		pls=${sortprio[$j]}
		split=$(echo ${sortprio[$j]} | sed -e 's/,/ /g')
		getPnumber $split
		if [[ $pron == $i ]]
		then
			arr_contains print_copy $pls
			if [[ $in == 1 ]]
			then
				continue
			else
				print_copy+=( $pls )
				break
			fi
		fi
	done
done


#ORIGINAL PROCESS SEQUENCE IS SORTPRIO
echo -e "*******************************************************\n"
echo -e "\nNON-PREEMPTIVE PRIORITY\n"
echo -e "Process\tBurst\tArrival\tPriority Waiting Turn-around"
avewt=''
avett=''
for i in "${!print_copy[@]}"
do
	curry=${print_copy[$i]}
	printone ()
	{
		echo -e "$1 \t $3 \t $2 \t $4 \t $5 \t $6"
		if [[ $avewt == '' ]]
		then
			avewt=($5)
		else
			avewt=$(( $avewt + $5 ))
		fi
		if [[ $avett == '' ]]
		then
			avett=($6)
		else
			avett=$(( $avett + $6 ))
		fi
	}
	split=$(echo $curry | sed -e 's/,/ /g')
	printone $split
done
echo "Average Waiting Time: $(( $avewt / ${#print_copy[@]} ))"
echo -e "Average Turnaround Time: $(( $avett / ${#print_copy[@]} ))\n"

echo -e "Non-Preemptive Gantt Chart"
echo -n "|0"
for i in "${!print_copy[@]}"
do
	curry=${sortprio[$i]}
	printone ()
	{
		echo -n "|    $1    |$6"
	}
	split=$(echo $curry | sed -e 's/,/ /g')
	printone $split
done
echo -n "|"
echo -e " "
echo -e "\n*******************************************************\n"

echo -e "\n*******************************************************\n"

#PREEMPTIVE SHORTEST JOB FIRST

bur=$(cut -d ',' -f 3 $name | sort -n)
sortarr=''
totalb=''
#sort by CPU burst
for i in $bur
do
	for j in "${!newarr[@]}"
	do
		pls=${newarr[$j]}
		split=$(echo ${newarr[$j]} | sed -e 's/,/ /g')
		getBurst $split
		if [[ $bt == $i ]]
		then
			if [[ $sortarr == '' ]]
			then
				sortarr=( $pls )
				break
			else
				arr_contains sortarr $pls
				if [[ $in == 1 ]]
				then
					continue
				else
					sortarr+=( $pls )
					break
				fi
			fi
		fi
	done
	totalb="$(($totalb + $i))"
done

#sort by process number
print_copy=()
for i in "${arrange[@]}"
do
	for j in "${!sortarr[@]}"
	do
		pls=${sortarr[$j]}
		split=$(echo ${sortarr[$j]} | sed -e 's/,/ /g')
		getPnumber $split
		if [[ $pron == $i ]]
		then
			arr_contains print_copy $pls
			if [[ $in == 1 ]]
			then
				continue
			else
				print_copy+=( $pls )
				break
			fi
		fi
	done
done

#get cpu bursts of processes in order
bursts=()
for i in "${!print_copy[@]}"
do
	pre=${print_copy[$i]}
	split=$(echo $pre | sed -e 's/,/ /g')
	getBurst $split
	bursts+=($bt)
done

temparr=()
new_temp=()
counter=0
prefinalsjf=()

#decrement process burst
dec_burst () {
	dec="$(($3 - 1))"
	newspl=$(echo $1 $2 $dec $4 $5 $6 | sed -e 's/ /,/g')
}
#add process waiting time
add_wait () {
	add="$(($5 + 1))"
	newspl=$(echo $1 $2 $3 $4 $add $6 | sed -e 's/ /,/g')
}
#forms final element to be added to sequence with computed turnaround time
form_element () {
	turnaround="$(($counter + 1))"
	form=$(echo $1 $2 $3 $4 $5 $turnaround | sed -e 's/ /,/g')
}

#sort final preemptive sjf
sequence=()
while [[ $counter != $(($totalb + 1)) ]];
do
	#puts all arrived processes into temparray
	for i in "${!sortarr[@]}"
	do
		current=${sortarr[$i]}
		if [[ $current != '' ]]; then
			split=$(echo $current | sed -e 's/,/ /g')
			getArrTime $split
			getBurst $split
			if (( $at <= $counter )) && [[ $bt > 0 ]];
			then
				temparr+=($current)
			fi
		fi
	done

	#checks if running process and next process have the same burst times
	#if processes have the same burst times --> pick next process by FCFS
	tempcount=${#temparr[@]}
	if [[ $tempcount > 1 ]]
	then
		one=${temparr[0]}
		two=${temparr[1]}
		splitone=$(echo $one | sed -e 's/,/ /g')
		splittwo=$(echo $two | sed -e 's/,/ /g')
		getBurst $splitone
		oneb=$bt
		getBurst $splittwo
		twob=$bt
		if [[ $oneb == $twob ]]
		then
			new_temparr=()
			for i in "${arrange[@]}"
			do
				for j in "${!temparr[@]}"
				do
					pls=${temparr[$j]}
					split=$(echo ${temparr[$j]} | sed -e 's/,/ /g')
					getPnumber $split
					if [[ $pron == $i ]]
					then
						arr_contains new_temparr $pls
						if [[ $in == 1 ]]
						then
							continue
						else
							new_temparr+=( $pls )
							break
						fi
					fi
				done
			done
			chosen=${new_temparr[0]}
		else
			chosen=${temparr[0]}
		fi
	else
		chosen=${temparr[0]}
	fi

	#checks if next process has lower burst than process to be preempted
	#if next process has lower burst --> context switch
	qcount=${#sequence[@]}
	if [[ $qcount != 0 ]]
	then
		temp=${sequence[$((qcount - 1))]}
		if [[ $temp != '' ]]
		then
			if [[ $chosen != $temp ]]
			then
				split=$(echo $temp | sed -e 's/,/ /g')
				splittwo=$(echo $chosen | sed -e 's/,/ /g')
				getBurst $splittwo
				two=$bt
				getBurst $split
				one=$bt
				if [[ $one != "0" ]]
				then
					if (( $one <= $two ))
					then
						chosen=$temp
					fi
				fi
			fi
		fi
	fi

	#takes next process to be run, decrements CPU burst and adds waiting times to other processes
	#when cpu burst = 0, use current counter time as turnaround time and remove from array
	for element in "${!sortarr[@]}";
	do
		elle=${sortarr[$element]}
		spl=$(echo $elle | sed -e 's/,/ /g')
		getBurst $spl
        if [[ $elle == $chosen ]];
        then
            dec_burst $spl
            split=$(echo $newspl | sed -e 's/,/ /g')
            getBurst $split
            if [[ $bt == 0 ]]
            then
            	unset sortarr[$element]
            	sequence+=($newspl)

            	form_element $split
            	prefinalsjf+=($form)

            else
          		sortarr[$element]=$newspl
            	sequence+=($newspl)
            fi
        else
        	getArrTime $spl
        	if (( $counter >= $at ))
        	then
	        	add_wait $spl
	        	sortarr[$element]=$newspl
	        fi
        fi
        getBurst $spl
        if [[ $bt == 0 ]]; then
        	form_element $spl
        	prefinalsjf+=($form)
        	unset sortarr[$element]
		fi
    done
	temparr=( "${new_temp[@]}" )
	((counter++))

done

#sort by process number
print_copy=()
for i in "${arrange[@]}"
do
	for j in "${!prefinalsjf[@]}"
	do
		pls=${prefinalsjf[$j]}
		split=$(echo ${prefinalsjf[$j]} | sed -e 's/,/ /g')
		getPnumber $split
		if [[ $pron == $i ]]
		then
			arr_contains print_copy $pls
			if [[ $in == 1 ]]
			then
				continue
			else
				print_copy+=( $pls )
				break
			fi
		fi
	done
done

#puts burst times back for printing table
replace_burst ()
{
	new=$(echo $1 $2 $7 $4 $5 $6 | sed -e 's/ /,/g')
}

#sorts by process number for printing
prefinalsjf=()
for i in "${!print_copy[@]}"
do
	for j in "${!bursts[@]}"
	do
		if [[ $i == $j ]]
		then
			get=${print_copy[$i]}
			bur=${bursts[$i]}
			split=$(echo $get | sed -e 's/,/ /g')
			replace_burst $split $bur
			prefinalsjf+=($new)
			break
		fi
	done
done

#ORIGNAL SEQUENCE IS $SEQUENCE

echo -e "PREEMPTIVE SHORTEST JOB FIRST\n"
echo -e "Process\tBurst\tArrival\tPriority Waiting Turn-around"
for i in "${!prefinalsjf[@]}"
do
	curry=${prefinalsjf[$i]}
	printone ()
	{
		echo -e "$1 \t $3 \t $2 \t $4 \t $5 \t $6"
		if [[ $avewt == '' ]]
		then
			avewt=($5)
		else
			avewt=$(( $avewt + $5 ))
		fi
		if [[ $avett == '' ]]
		then
			avett=($6)
		else
			avett=$(( $avett + $6 ))
		fi
	}
	split=$(echo $curry | sed -e 's/,/ /g')
	printone $split
done
echo "Average Waiting Time: $(( $avewt / ${#prefinalsjf[@]} ))"
echo -e "Average Turnaround Time: $(( $avett / ${#prefinalsjf[@]} ))\n"
echo "Preemptive SJF Gantt Chart"
for i in "${!sequence[@]}"
do
	andii=${sequence[i]}
	meg=${sequence[$((i-1))]}
	splitandii=$(echo $andii | sed -e 's/,/ /g')
	splitmeg=$(echo $meg | sed -e 's/,/ /g')
	getPnumber $splitandii
	pandii="$pron"
	getPnumber $splitmeg
	pmeg="$pron"

	if [[ $i == 0 ]]
	then
		echo -n "|$i|    P$pandii    |"
	fi

	if [[ $pandii != $pmeg ]]
	then
		echo -n "$i|    P$pandii    |"
	fi

	if [[ $pandii == $alex ]]
	then
		echo -n "$i|"
	fi

done

echo -n "${#sequence[@]}|"
echo -e " "

echo -e "\n*******************************************************\n"



#get start time ST = TT - Arrival - Burst
#get end time = TT - ST
#create gantt chart array
#sort by end time

#PREEMPTIVE PRIORITY

pri=$(cut -d ',' -f 4 $name | sort -n)
bur=$(cut -d ',' -f 3 $name | sort -n)
sortarr=''
totalb=''

#sort by priority
for i in $pri
do
	for j in "${!newarr[@]}"
	do
		pls=${newarr[$j]}
		split=$(echo ${newarr[$j]} | sed -e 's/,/ /g')
		getPrio $split
		if [[ $pr == $i ]]
		then
			if [[ $sortarr == '' ]]
			then
				sortarr=( $pls )
				break
			else
				arr_contains sortarr $pls
				if [[ $in == 1 ]]
				then
					continue
				else
					sortarr+=( $pls )
					break
				fi
			fi
		fi
	done
done

#computes total burst time
for i in $bur
do
	totalb="$(($totalb + $i))"
done

#arranges by process number for printing table
print_copy=()
for i in "${arrange[@]}"
do
	for j in "${!sortarr[@]}"
	do
		pls=${sortarr[$j]}
		split=$(echo ${sortarr[$j]} | sed -e 's/,/ /g')
		getPnumber $split
		if [[ $pron == $i ]]
		then
			arr_contains print_copy $pls
			if [[ $in == 1 ]]
			then
				continue
			else
				print_copy+=( $pls )
				break
			fi
		fi
	done
done

#gets CPU bursts of processes in proper order
bursts=()
for i in "${!print_copy[@]}"
do
	pre=${print_copy[$i]}
	split=$(echo $pre | sed -e 's/,/ /g')
	getBurst $split
	bursts+=($bt)
done

temparr=()
new_temp=()
counter=0
prefinalprio=()
sequence=()
while [[ $counter != $(($totalb + 1)) ]];
do
	#puts arrived processes in temp array
	for i in "${!sortarr[@]}"
	do
		current=${sortarr[$i]}
		if [[ $current != '' ]]; then
			split=$(echo $current | sed -e 's/,/ /g')
			getArrTime $split
			getBurst $split
			if (( $at <= $counter )) && [[ $bt > 0 ]];
			then
				temparr+=($current)
			fi
		fi
	done
	#checks if running process and next process have the same priority values
	#if the same --> choose by FCFS
	tempcount=${#temparr[@]}
	if [[ $tempcount > 1 ]]
	then
		one=${temparr[0]}
		two=${temparr[1]}
		splitone=$(echo $one | sed -e 's/,/ /g')
		splittwo=$(echo $two | sed -e 's/,/ /g')
		getPrio $splitone
		onep=$pr
		getPrio $splittwo
		twop=$pr
		if [[ $onep == $twop ]]
		then
			new_temparr=()
			for i in "${arrange[@]}"
			do
				for j in "${!temparr[@]}"
				do
					pls=${temparr[$j]}
					split=$(echo ${temparr[$j]} | sed -e 's/,/ /g')
					getPrio $split
					if [[ $pr == $onep ]]; then
						getPnumber $split
						if [[ $pron == $i ]]
						then
							arr_contains new_temparr $pls
							if [[ $in == 1 ]]
							then
								continue
							else
								new_temparr+=( $pls )
								break
							fi
						fi
					fi
				done
			done
			chosen=${new_temparr[0]}
		else
			chosen=${temparr[0]}
		fi
	else
		chosen=${temparr[0]}
	fi

	#takes next process to be run, decrements CPU burst and adds waiting times to other processes
	#when cpu burst = 0, use current counter time as turnaround time and remove from array
	for element in "${!sortarr[@]}";
	do
		elle=${sortarr[$element]}
		spl=$(echo $elle | sed -e 's/,/ /g')
		getBurst $spl
        if [[ $elle == $chosen ]];
        then
            dec_burst $spl
            split=$(echo $newspl | sed -e 's/,/ /g')
            getBurst $split
            if [[ $bt == 0 ]]
            then
            	unset sortarr[$element]
            	sequence+=($newspl)

            	form_element $split
            	prefinalprio+=($form)

            else
          		sortarr[$element]=$newspl
            	sequence+=($newspl)
            fi
        else
        	getArrTime $spl
        	if (( $counter >= $at ))
        	then
	        	add_wait $spl
	        	sortarr[$element]=$newspl
	        fi
        fi
        getBurst $spl
    done
	temparr=( "${new_temp[@]}" )
	((counter++))
done


#sort by process number for printing tables
print_copy=()
for i in "${arrange[@]}"
do
	for j in "${!prefinalprio[@]}"
	do
		pls=${prefinalprio[$j]}
		split=$(echo ${prefinalprio[$j]} | sed -e 's/,/ /g')
		getPnumber $split
		if [[ $pron == $i ]]
		then
			arr_contains print_copy $pls
			if [[ $in == 1 ]]
			then
				continue
			else
				print_copy+=( $pls )
				break
			fi
		fi
	done
done

#puts original burst times back for printing
replace_burst ()
{
	new=$(echo $1 $2 $7 $4 $5 $6 | sed -e 's/ /,/g')
}

#sorts by process number for printing
prefinalprio=()
for i in "${!print_copy[@]}"
do
	for j in "${!bursts[@]}"
	do
		if [[ $i == $j ]]
		then
			get=${print_copy[$i]}
			bur=${bursts[$i]}
			split=$(echo $get | sed -e 's/,/ /g')
			replace_burst $split $bur
			prefinalprio+=($new)
			break
		fi
	done
done

echo -e "PREEMPTIVE PRIORITY\n"
echo -e "Process\tBurst\tArrival\tPriority Waiting Turn-around"
for i in "${!prefinalprio[@]}"
do
	curry=${prefinalprio[$i]}
	printone ()
	{
		echo -e "$1 \t $3 \t $2 \t $4 \t $5 \t $6"
		if [[ $avewt == '' ]]
		then
			avewt=($5)
		else
			avewt=$(( $avewt + $5 ))
		fi
		if [[ $avett == '' ]]
		then
			avett=($6)
		else
			avett=$(( $avett + $6 ))
		fi
	}
	split=$(echo $curry | sed -e 's/,/ /g')
	printone $split
done
echo "Average Waiting Time: $(( $avewt / ${#prefinalprio[@]} ))"
echo -e "Average Turnaround Time: $(( $avett / ${#prefinalprio[@]} ))\n"

echo "Preemptive Priority Gantt Chart"
for i in "${!sequence[@]}"
do
	andii=${sequence[i]}
	ngek=$(($i - 1))
	meg=${sequence[$ngek]}
	splitandii=$(echo $andii | sed -e 's/,/ /g')
	splitmeg=$(echo $meg | sed -e 's/,/ /g')
	getPnumber $splitandii
	pandii="$pron"
	getPnumber $splitmeg
	pmeg="$pron"

	if [[ $i == 0 ]]
	then
		echo -n "|$i|     "P"$pandii     |"
	fi

	if [[ $pandii != $pmeg ]]
	then
		echo -n "$i|     "P"$pandii     |"
	fi

	if [[ $pandii == $alex ]]
	then
		echo -n "$i|"
	fi

done

echo -n "${#sequence[@]}|"
echo -e " "

echo -e "\n*******************************************************\n"
