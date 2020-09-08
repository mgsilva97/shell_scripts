#!/bin/bash
# Desenvolvido por p543596 (Michael Gomes da Silva)
# Este script foi desenvolvido para realizar alteração de hostname de equipamentos Linux das agências Caixa Economica

menu() 
	{

clear
echo "#################################################################"
echo "#                                                               #"
echo "# Script desenvolvido por p543596 (Michael Gomes da Silva)      #"
echo "#                                                               #"
echo -e "#                       ALTERA HOSTNAME v1.1                    #" 
echo "#                                                               #"
echo -e "#  v1.0 = Criacao do Script                                     #"
echo -e "#  v1.1 = Inclusao do /etc/hosts na alteracao do hostname       #"
echo "#                                                               #"
echo -e "#\tPlataformas suportadas: TO, TH, EC, SX                  #"
echo "#                                                               #"
echo "#################################################################"
echo ""
echo ""


ETCHOSTNAME="/etc/hostname"
ETCHOSTS="/etc/hosts"
HOST=$(cat $ETCHOSTNAME)

echo -e "\t\t######## MENU PRINCIPAL ########"
echo ""
echo ""
echo "1. Alterar hostname"
echo "99. Sair"
echo ""
echo -n "Digite a opcao desejada: "
read -e OPCAO

case "$OPCAO" in

	1)
		echo "O hostname atual e $HOST"	
		echo -n "Deseja alterar? [y/N]: "
		read -e RESPOSTA

			case "$RESPOSTA" in

        	[yY])
                	echo -n "Digite o novo hostname: "
                	read -e NOVOHOSTNAME
			echo "Nome atual: $HOST"
			echo "Novo Nome: $NOVOHOSTNAME"
                	echo -n "Confirma a seguinte alteracao? [y/N]: "
			read -e CONFALTERACAO	

				case "$CONFALTERACAO" in

				[yY])
					echo "Realizando alteracao. Aguarde..."
					sleep 4 	
					sed -i "s/$HOST/$NOVOHOSTNAME/g" $ETCHOSTNAME

					grep -i "$HOST" $ETCHOSTS >> /dev/null

						if [ "$?" -eq 0 ]; then

							sed -i "s/$HOST/$NOVOHOSTNAME/gI" $ETCHOSTS
						else
							echo "" >> $ETCHOSTS
							echo -e "127.0.0.1\t$NOVOHOSTNAME" >> $ETCHOSTS

						fi
								
					echo "Reiniciando equipamento. Aguarde..."
					sleep 3
					shutdown -r now				
						;;
				""|[nN])
					echo "Alteracao nao realizada!"
					sleep 3
					clear
					menu					
						;;
				*)
					echo "OPCAO ERRADA!"
					sleep 3
					clear
					menu
						;;
				esac
					;;

		""|[nN]) 
			clear
			menu
				;;
		*)
			echo "OPCAO ERRADA!"
			sleep 3
			clear
			menu
				;;
			esac
		;;
	99) 
		echo "Saindo..."
		sleep 2 
		clear
		exit 0
			;;	
	*)
		echo "OPCAO ERRADA!"
		sleep 3
		clear
			menu
			;;
esac
}

## SCRIPT INICIA AQUI
while :
	do
		menu
	done
