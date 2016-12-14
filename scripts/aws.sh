#!/bin/bash
TEMP_SCRIPT_DIR=`dirname -- "$0"`
SCRIPT_DIR=`cd $TEMP_SCRIPT_DIR; pwd`
cd $SCRIPT_DIR/..
INVENTORY="inventory/"
PROVISION="provision.yml"
VPC="vpc.yml"
INFRA="infra.yml"

function title
{
RED='\033[0;31m'
NC='\033[0m'
printf "${RED}Note: If this script fails, please take a look at the contents and uncomment lines that you think may be required${NC}\n"
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

function display_help() {
    echo "   -c, --create-user              Create new ssh user"
    echo "   -d, --delete-user              Delete existing ssh user"
    echo "   -v, --create-vpc               Create new VPC"
    echo "   -r, --renew-certs              Create or Renew Lets encrypt certificate"
    echo "   -s, --spinup                   Spinup new instance"
    echo "   -h, --help                     Help"
    echo "   -r, --renew-certs              Create or Renew Lets encrypt certificate"
    echo "   -p, --update-proxy             Update proxy configuration"
    echo "   -ci, --provision-ci            Provision CI Agent"
    echo "   -ea, --provision-erpagent      Provision ERP Agent"
    echo "   -ba, --provision-buildagent    Provision Build Agent"
    echo
}


case "$1" in
-c | --create-user)
    update-user
    ;;
-d | --delete-user)
    update-user
    ;;

-v |--create-vpc)
    create-vpc
    ;;
-r |--renew-certs)
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

-h | --help)
    display_help  # Call your function
    exit 0
    ;;
*)
    echo $"Usage: $0 {create-user|delete-user|create-vpc|renew-certs|spinup-instance|update-proxy|provison-buildserver|provision-erpagent|provision-buildagent|help}"
    exit 1
esac
