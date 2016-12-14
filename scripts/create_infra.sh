#!/usr/bin/env bash

#This tells you stuff that you need on your machine in order to run the plays mentioned.

TEMP_SCRIPT_DIR=`dirname -- "$0"`
SCRIPT_DIR=`cd $TEMP_SCRIPT_DIR; pwd`
cd $SCRIPT_DIR/..


RED='\033[0;31m'
NC='\033[0m' # No Color
printf "${RED}Note: If this script fails, please take a look at the contents and uncomment lines that you think
may be required${NC}\n"


# Ansible - Ensure you have something >2.1
#brew install ansible

# Python modules that we use
# pip install boto
# pip install awscli

# echo "Configuring aws-cli. Remember to remove this step once we move to ansible 2.2. "
# echo "Please decrypt secure_vars.yml to find the right values"
# aws-configure

# echo "Setting up ssh agent and adding bahmni launch key"
# eval "$(ssh-agent -s)"
# ansible decrypt group_vars/bahmni_launch_key.pem
# ssh-add group_vars/bahmni_launch_key.pem


#ansible-playbook -i infra_inventory infra.yml -vvv
