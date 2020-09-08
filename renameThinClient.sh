#!/bin/bash
# Desenvolvido por p543596 (Michael Gomes da Silva)
# Este script foi desenvolvido para realizar alteração de hostname em massa dos ThinClients das agências Caixa Economica.
# O mesmo consiste em alterar todos os ThinClients do padrão antigo (Ex: RJ0125TH206) para o padrão novo (Ec: RJ0125TH306)


clear 
echo ""

if [ -z "$1" ]
  then
    echo "Usage: `echo $0` hosts.txt"
        exit 1
else

THIN=$(cat $1)
USER="root"
PASS="pass"
COMANDO2="sed -i 's/[Tt][Hh]2/TH3/g' /etc/hosts && sleep 2 && shutdown -r now"
NOW=$(date +'%Y%m%d%H%M%S')

	echo "NOMEANTIGO;NOMENOVO" > "logs/renameTH_$NOW.log" 2>&1 

for i in $THIN

	do
		
	OLDNAME="$i"

	sshpass -p $PASS ssh -q -o "StrictHostKeyChecking=no" -o "ConnectTimeout=5" $USER@$i $COMANDO2

	if [ $? != "0" ]

		then

		PASS1="pass"
			
		sshpass -p $PASS1 ssh -q -o "StrictHostKeyChecking=no" -o "ConnectTimeout=5" $USER@$i $COMANDO2
	fi
		
		
	sleep 5 
	NEWNAME=$(echo "$i" | sed 's/[Tt][Hh]2/TH3/g')
	
	echo "$OLDNAME;$NEWNAME" >> "logs/renameTH_$NOW.log" 2>&1 

	done
	
	/usr/bin/dos2unix -q "logs/renameTH_$NOW.log" 2>&1  	

fi
