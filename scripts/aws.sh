#!/bin/bash
TEMP_SCRIPT_DIR=`dirname -- "$0"`
SCRIPT_DIR=`cd $TEMP_SCRIPT_DIR; pwd`
cd $SCRIPT_DIR/..
INVENTORY="inventory/"
PROVISION="provision.yml"
VPC="vpc.yml"
INFRA="infra.yml"
BASTION="bastion.yml"

function title
{
RED='\033[0;31m'
NC='\033[0m'
printf "${RED}Note: ############# ${NC}\n"
}

function update-user
{
   title
   echo -e "\033[01;35m---------- Update/Delete ssh user ----------"
   ansible-playbook -i $INVENTORY $INFRA -t ssh_user -vvv

}

function create-vpc
{
   title
   echo -e "\033[01;35m---------- Creating Virtual Private Cloud in AWS ----------"
   ansible-playbook -i $INVENTORY $VPC -vvv

}

function renew-certs
{
   title
   echo -e "\033[01;35m---------- Create/Renew Certficate ----------"
   ansible-playbook -i $INVENTORY $PROVISION -t renew_certs -vvv

}

function spinup-instance
{
   title
   echo -e "\033[01;35m---------- Spinup Instance ----------"
   ansible-playbook -i $INVENTORY $INFRA -vvv

}

function update-proxy
{
   title
   echo -e "\033[01;35m---------- Update proxy configuration ----------"
   ansible-playbook -i $INVENTORY $PROVISION -t update_proxy -vvv

}

function provision-build-server
{
   title
   echo -e "\033[01;35m---------- Provision Build Server ----------"
   ansible-playbook -i $INVENTORY $PROVISION -t provision_build_server -vvv
}

function provision-erpagent
{
   title
   echo -e "\033[01;35m---------- Provision ERP Build Agent ----------"
   ansible-playbook -i $INVENTORY $PROVISION -t provision_erp_build_agent -vvv

}

function provision-buildagent
{
   title
   echo -e "\033[01;35m---------- Provision-build-agent ----------"
   ansible-playbook -i $INVENTORY $PROVISION -t provision_build_agent -vvv

}

function bastion-server
{
   title
   echo -e "\033[01;35m---------- Bastion Server ----------"
   ansible-playbook -i ec2.py $BASTION -vvv

}

function display_help() {
   cat <<- _EOF_
   Options:

    -r, --refresh-users             Refresh user list in all machines
                                    Make sure correct user details are present in "users.yml".

    -v, --create-vpc                Create new VPC in AWS
                                    Further to create the new VPC in a different Amazon region change the AWS region in playbook.

    -c, --renew-certs               Install or Renew Lets encrypt certificate
                                    It will renew the "Lets encrypt" certificate in all the machines.

    -s, --spinup                    Spinup new instance
                                    Make sure include the name and specs of the new instance in the "Instance.yml".

    -h, --help                      Display this help message

    -p, --update-proxy              Update proxy configuration
                                    All bahmini server instances would be added in Haproxy configuration.

    -bs, --provision-buildserver    Provision CI Server
    -ea, --provision-erpagent       Provision ERP Agent
    -ba, --provision-buildagent     Provision Build Agent
    -br, --provision-bastionserver  Provision Bastion Server
    -cr, --provision-controller     Provision Ansible controller
_EOF_
}


case "$1" in
-r | --refresh-user)
    update-user
    ;;
-v |--create-vpc)
    create-vpc
    ;;
-c |--renew-certs)
    renew-certs
    ;;
-s |--spinup)
    spinup-instance
    ;;
-p |--update-proxy)
    update-proxy
    ;;
-bs |--provision-buildserver)
    provision-build-server
    ;;
-ea |--provision-erpagent)
    provision-erpagent
    ;;
-ba |--provision-buildagent)
    provision-buildagent
    ;;
-br |--provision-bastionserver)
    bastion-server
    ;;

-h | --help)
    display_help  # Call your function
    exit 0
    ;;
*)
    echo $"Usage: $0 {refresh-user|bastion-server|create-vpc|renew-certs|spinup-instance|update-proxy|provison-buildserver|provision-erpagent|provision-buildagent|help}"
    exit 1
esac
