#!/bin/bash
# Script desenvolvido por Michael Gomes para realizar atividades que envolvem os force new deployments do ECS
# v1.0 - Versao inicial - OK
# v1.1 - Adicionar logs e formatar o output na tela e no arquivo de log para text - OK
# v1.2 - Adicionar funcao para configuracao inicial de primeiro uso - OK
# v1.2.2 - Adicionar snapshot dos bancos de producao - OK


    ### Configuracoes Iniciais ### - TODO Testar

# Criar diretorio /var/log/ecs_force_deploy/logs - OK
# Criar diretorio /var/log/ecs_force_deploy/config - OK
# Configurar as credenciais de usuario usando o aws configure - OK
# Configurar os perfis de switchRole no arquivo .aws/config - OK

# Declaracao das variaveis (producao)

ARGV=$1
MAIN_PATH=/var/log/ecs_force_deploy
CONFIG_PATH=/config
LOGS_PATH=/logs
NOW=`date +"%Y%m%d-%H%M"`
LOG_FILE="$MAIN_PATH$LOGS_PATH/ecs_force_deploy-$NOW.log"
REGION="us-east-1"
PROFILE="production"
CLUSTER="aws-ecs-cluster-name-here"
BACKEND="aws-ecs-service-name-here"
CELERY_WORKER_DEFAULT="aws-ecs-service-name-here"
CELERY_WORKER_HIGH_PRIORITY="aws-ecs-service-name-here"
CELERY_WORKER_LOW_PRIORITY="aws-ecs-service-name-here"
CELERY_BEAT="aws-ecs-service-name-here"
DB_NOVO_NAME="aws-rds-database-name-here"
DB_ANTIGO_NAME="aws-rds-database-name-here"

# Valida se ha argumentos ou nao. Sempre deve haver um argumento.

echo "" > $LOG_FILE # Cria o arquivo de logs

valida_args() {

if [ $# -eq 0 ]
  then
    echo -e "Voce deve adicionar argumentos ao script:\n- backend\n- celery_default\n- celery_high\n- celery_low\n- celery_beat\n- all\n- config\n -snapshot"
    echo ""
    echo "Exemplo: `echo $0` config"
fi

}

    ### Declaracao das funcoes ###

# forcar deploy do backend
force_new_deploy_backend() {

aws ecs update-service \
    --cluster $CLUSTER \
    --service $BACKEND \
    --force-new-deployment \
    --profile $PROFILE \
    --region $REGION \
    --output text | tee $LOG_FILE

}
force_new_deploy_celery_worker_default() {

aws ecs update-service \
    --cluster $CLUSTER \
    --service $CELERY_WORKER_DEFAULT \
    --force-new-deployment \
    --profile $PROFILE \
    --region $REGION \
    --output text | tee $LOG_FILE

}

# forcar deploy do celery high priority
force_new_deploy_celery_worker_high_priority() {

aws ecs update-service \
    --cluster $CLUSTER \
    --service $CELERY_WORKER_HIGH_PRIORITY \
    --force-new-deployment \
    --profile $PROFILE \
    --region $REGION \
    --output text | tee $LOG_FILE

}

# forcar deploy do celery low priority
force_new_deploy_celery_worker_low_priority() {

aws ecs update-service \
    --cluster $CLUSTER \
    --service $CELERY_WORKER_LOW_PRIORITY \
    --force-new-deployment \
    --profile $PROFILE \
    --region $REGION \
    --output text | tee $LOG_FILE

}
# forcar deploy do celery beat

force_new_deploy_celery_beat() {

aws ecs update-service \
    --cluster $CLUSTER \
    --service $CELERY_BEAT \
    --force-new-deployment \
    --profile $PROFILE \
    --region $REGION \
    --output text | tee $LOG_FILE

}

# forcar deploy de todos os servicos
force_new_deploy_all() {

force_new_deploy_celery_worker_default
force_new_deploy_celery_worker_high_priority
force_new_deploy_celery_worker_low_priority
force_new_deploy_celery_beat
force_new_deploy_backend

}

# Primeira vez utilizando o script? Rode esta funcao atraves do argumento config (ex: ./script.sh config)
first_time_configuration() {

clear
echo "### Iniciando configuracao inicial ###"
sleep 1

echo "Criando diretorio $MAIN_PATH$LOGS_PATH"
mkdir -p "$MAIN_PATH$LOGS_PATH"
cd $MAIN_PATH
sleep 1

echo "Criando diretorio $CONFIG_PATH"
mkdir $CONFIG_PATH
cd $CONFIG_PATH
sleep 1

echo "Instalando curl, unzip e sudo"

apt-get install curl unzip sudo -y

echo "Instalando AWS CLI"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo "Configure a AWS CLI"
aws configure
sleep 1

echo "Configurando SwitchRoles no arquivo .aws/config"
cp ~/.aws/config ~/.aws/config.$NOW.bkp

echo "[profile read-prod]
    role_arn = arn:aws:iam::AWS-ACCOUNTID:role/SwitchRole-ReadAndSomeWriteAccess 
    source_profile = default

[profile domains]
    role_arn = arn:aws:iam::AWS-ACCOUNTID:role/SwitchRole-AdminFullAccess
    source_profile = default

[profile cloudfront]
    role_arn = arn:aws:iam::AWS-ACCOUNTID:role/SwitchRole-AdminFullAccess
    source_profile = default

[profile production]
    role_arn = arn:aws:iam::AWS-ACCOUNTID:role/SwitchRole-AdminFullAccess
    source_profile = default" > ~/.aws/config

echo "done."

}

# Snapshot dos bancos antigo e novo
snapshot() {

echo -n "Deseja realizar um snapshot? [Y/N]: "
read -e CONFIRMA

case $CONFIRMA in 
    [yY])
        echo "1. Banco sistema ANTIGO"
        echo "2. Banco sistema NOVO"
        echo -n "Digite a opcao desejada: "
        read -e OPCAO

            case $OPCAO in
                1) 
                    aws rds create-db-snapshot \
                        --db-snapshot-identifier "$DB_ANTIGO_NAME-$NOW" \
                        --db-instance-identifier "$DB_ANTIGO_NAME" \
                        --profile $PROFILE \
                        --region $REGION \
                        --output text | tee $LOG_FILE
                        7minutes
                                ;;

                
                2)
                    aws rds create-db-cluster-snapshot \
                        --db-cluster-snapshot-identifier "$DB_NOVO_NAME-$NOW" \
                        --db-cluster-identifier "$DB_NOVO_NAME" \
                        --profile $PROFILE \
                        --region $REGION \
                        --output text | tee $LOG_FILE
                        7minutes
                                ;;

                *)
                    echo ""
                    echo "Opcao Invalida"
                    snapshot
                        ;;
            esac
            
            ;;

    ""|[nN])
        sleep 1
            ;;

    *)
        echo "Opcao Invalida"
        snapshot
            ;;
esac

}

7minutes() {

    # For para contagem regressiva de 7 minutos
        echo ""
        for((i = 8; i >= 1; i--))
            do
                echo "Aguarde $i minuto(s) para validar"
                sleep 60
            done
}

# case para decidir quais funcoes chamar
echo >> $LOG_FILE

case $ARGV in
    backend)
        force_new_deploy_backend
        7minutes
            ;;

    celery_default)
        force_new_deploy_celery_worker_default
        echo "Por favor, acompanhe o deploy pela console"
            ;;

    celery_high)
        force_new_deploy_celery_worker_high_priority
        echo "Por favor, acompanhe o deploy pela console"
            ;;

    celery_low)
        force_new_deploy_celery_worker_low_priority
        echo "Por favor, acompanhe o deploy pela console"
            ;;
    
    celery_beat)
        force_new_deploy_celery_beat
        echo "Por favor, acompanhe o deploy pela console"
            ;;
            
    all)
        force_new_deploy_all
        echo "Por favor, acompanhe o deploy pela console"
            ;;

    config)
        first_time_configuration
            ;;

    snapshot)
        snapshot
            ;;
    *)
        valida_args
            ;;
esac