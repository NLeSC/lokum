#!/bin/bash

set -e

if [ "$1" = 'deploy' ]; then

    if [ -d "$LOKUM_CONFIG" ]; then

        echo "Starting the deployment."

        export DEPLOY_FOLDER=$LOKUM_HOME/deployment/cluster$(ls /lokum/deployment/ | wc -l)

        echo "Deployment folder: "$DEPLOY_FOLDER
        mkdir -p $DEPLOY_FOLDER && cd $DEPLOY_FOLDER

        # generate the ssh-key
        echo "Generating the ssh-key for root user."
        ssh-keygen -b 4096 -t rsa -f id_rsa_lokum_root.key -q -P ""
        cp -v $DEPLOY_FOLDER/id_rsa_lokum_root.key /lokum/id_rsa_lokum_root.key
        cp -v $DEPLOY_FOLDER/id_rsa_lokum_root.key.pub /lokum/id_rsa_lokum_root.key.pub
        echo "Generating the ssh-key for ubuntu user."
        ssh-keygen -b 4096 -t rsa -f id_rsa_lokum_ubuntu.key -q -P ""
        cp -v $DEPLOY_FOLDER/id_rsa_lokum_ubuntu.key /lokum/id_rsa_lokum_ubuntu.key
        cp -v $DEPLOY_FOLDER/id_rsa_lokum_ubuntu.key.pub /lokum/id_rsa_lokum_ubuntu.key.pub

        # fix for emma common role
        export CLUSTER_NAME=lokum # find a cleaner way
        cp -v $DEPLOY_FOLDER/id_rsa_lokum_ubuntu.key /lokum/emma/files/lokum.key
        cp -v $DEPLOY_FOLDER/id_rsa_lokum_ubuntu.key.pub /lokum/emma/files/lokum.key.pub
        cp -v $DEPLOY_FOLDER/id_rsa_lokum_ubuntu.key /lokum/emma/files/hadoop_id_rsa
        cp -v $DEPLOY_FOLDER/id_rsa_lokum_ubuntu.key.pub /lokum/emma/files/hadoop_id_rsa.pub



        cp -iR $LOKUM_CONFIG $DEPLOY_FOLDER/
        cd $DEPLOY_FOLDER/config
        terraform init && \
            terraform validate -var DEPLOY_FOLDER=$DEPLOY_FOLDER && \
            terraform apply -var DEPLOY_FOLDER=$DEPLOY_FOLDER

    else

        echo "Couldn't find the config files. Exiting."

    fi

else

    echo "Running $@"
    exec "$@"

fi
