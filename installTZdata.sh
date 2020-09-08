#/bin/bash
#Desenvolvido por p543596 (Michael Gomes)

wget ftp://ftp-server/Aplicativos/SISAG/PACOTE/tz-caixa_2.3_i386.deb

sudo dpkg -i tz-caixa_2.3_i386.deb

if [ $? -eq "0" ] 

	then

	sudo reboot

	else

	echo "Erro ao instalar tz-data"
	exit 10
fi
