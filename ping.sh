#!/bin/bash
#Desenvolvido por p543596 (Michael Gomes da Silva)
if [ -z "$1" ]
  then
    echo "Usage: ./ping.sh hosts.txt"
        exit
else

HOSTS=`cat $1 | awk '{print $1}'` 

for i in $HOSTS 
	do
	/bin/date >> "ping_status_`date +'%Y-%m-%d'`.txt" 2>&1
	/bin/ping -c4 $i.diretorio.caixa >> "ping_status_`date +'%Y-%m-%d'`.txt" 2>&1
	
		if [ $? != "0" ];
		then
			/bin/date >> "ping_status_`date +'%Y-%m-%d'`.txt" 2>&1
			/bin/ping -c4 $i.corp.caixa.gov.br >> "ping_status_`date +'%Y-%m-%d'`.txt" 2>&1
				
		fi

	done

      J=`cat hosts.txt | awk '{print $2}'`

            for j in $J
                
		do
        		/bin/date >> "ping_status_`date +'%Y-%m-%d'`.txt" 2>&1
   			/bin/ping -c4 $j >> "ping_status_`date +'%Y-%m-%d'`.txt" 2>&1
		done
fi
