#!/bin/bash
TEMP_SCRIPT_DIR=`dirname -- "$0"`
SCRIPT_DIR=`cd $TEMP_SCRIPT_DIR; pwd`
cd $SCRIPT_DIR/..
INVENTORY="inventory/"
PROVISION="provision.yml"
VPC="vpc.yml"
INFRA="infra.yml"
ALL_HOSTS="all.yml"
BASTION="bastion.yml"
CONTROLLER="controller.yml"
INSTANCE="manage_instance.yml"
INSTANCE_NAME='controller'

function refresh-user
{
   echo -e "\033[01;35m---------- Update/Delete ssh user ----------"
   ansible-playbook -i ${INVENTORY}/ec2.py $ALL_HOSTS -t manage_user -vvv

}

function create-vpc
{
   echo -e "\033[01;35m---------- Creating Virtual Private Cloud in AWS ----------"
   ansible-playbook -i $INVENTORY $VPC -vvv

}

function renew-certs
{
   echo -e "\033[01;35m---------- Create/Renew Certficate ----------"
   ansible-playbook -i $INVENTORY $PROVISION -t renew_certs -vvv

}

function spinup-instance
{
   echo -e "\033[01;35m---------- Spinup Instance ----------"
   ansible-playbook -i $INVENTORY $INFRA -vvv

}

function update-proxy
{
   echo -e "\033[01;35m---------- Update proxy configuration ----------"
   ansible-playbook -i $INVENTORY $PROVISION -t update_proxy -vvv

}

function provision-build-server
{
   echo -e "\033[01;35m---------- Provision Build Server ----------"
   ansible-playbook -i $INVENTORY $PROVISION -t provision_build_server -vvv
}

function provision-erpagent
{
   echo -e "\033[01;35m---------- Provision ERP Build Agent ----------"
   ansible-playbook -i $INVENTORY $PROVISION -t provision_erp_build_agent -vvv

}

function provision-buildagent
{
   echo -e "\033[01;35m---------- Provision-build-agent ----------"
   ansible-playbook -i $INVENTORY $PROVISION -t provision_build_agent -vvv

}

function bastion-server
{
   echo -e "\033[01;35m---------- Bastion Server ----------"
   ansible-playbook -i ec2.py $BASTION -vvv

}

function provision-controller
{

   ansible-playbook -i ${INVENTORY}/ec2.py $CONTROLLER -vvv

}

function start-instance
{

    ansible-playbook -i $INVENTORY $INSTANCE -e "instance_name=$input_instance_name" -t start_instance
}

function stop-instance
{
    ansible-playbook -i $INVENTORY $INSTANCE -e "instance_name=$input_instance_name" -t stop_instance
}

function display_help() {
echo -e "\n \033[3;0m Options: \n"
cat<<'EOF'
    -u, --refresh-users             Refresh user list in all machines
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
    -a,  --provision-controller     Provision Ansible controller
    -n,                             Instance name
    -st, --start-instance           start instance
    -si, --stop-instance            stop instance
EOF
echo -e "\033[3;91m\nNote:- Readme : \n"
echo -e "\033[1;30m"
cat<<'EOF'
   =====================================================================================================================
   Prerequisites
   -------------
   On the machine where you are running this script,
   Ensure you have Ansible > 2.1 setup in your machine
   Install python modules boto and awscli
    - pip install boto
    - pip install awscli

   Decrypt group_vars/aws_credentials.yml.
   ```ansible-vault decrypt group_vars/aws_credentials.yml```

   Configure aws-cli. Use AWS credentials provided in the aws_credentials.yml
   ```aws configure```

   Add launch key to connect to AWS
   eval "$(ssh-agent -s)"
   ansible decrypt group_vars/bahmni_launch_key.pem
   ssh-add group_vars/bahmni_launch_key.pem
   =====================================================================================================================
   Description
   -----------

   VPC Creation (-v, --create-vpc) :
        To create a new VPC, the following command is executed, "aws.sh -v".
        Further to create the new VPC in a different Amazon region the group_vars\aws_credentials.yml has to decrypted using
        ansible vault and change the AWS region.

   Spinup new instance (-s,--spinup) :
        To create a new Instance, the following command is executed, "aws.sh -s".
        Before executing the above command, including the name and specs of the new instance to be created in the instance.yml under config directory is mandatory.
        As a result of the above command, the instance will be created in respective vpc according to the configuration added.

   Add new user (-u, --refresh-users) :
        To add a new ssh user, the user.yml script under group_vars directory has to decrypted using ansible vault and the name and public key details
        of the new user has to be added and then the following command has to be executed, "aws.sh -u".

   Delete existing user (-u, --refresh-users) :
        To remove a particular user, the user.yml script under group_vars directory has to decrypted using ansible vault and the “state” of that
        particular user has to be change to “absent” and then the following command has to be executed, "aws.sh -u". 

   Renew lets encrypt certificate (-c, --renew-certs) :
        To renew the "Lets encrypt" certificate in all instances the following command has to be executed, "aws.sh -c".

   Update proxy configuration (-p, --update-proxy) :
        To update haproxy run the following command,  "aws.sh -p".
        As a result of the above command, all Bahmini server instances would be added in ha proxy configuration.

   Provision Build Server (-bs, --provision-buildserver) : To install and configure new GoServer, "aws.sh -bs".

   Provision Erpagent (-ea, --provision-erpagent) : To install and configure ERP build agent, "aws.sh -ea".

   Provision Build agent (-ba, --provision-buildagent) : To install and configure build agent, "aws.sh -ba".

   Provision Bastion Server ( -br, --provision-bastionserver) : To install and configure Bastion Server, "aws.sh -ba".

   Provision Controller (-a, --provision-controller ) : To provision ansible controller box, "aws.sh -a".
   =====================================================================================================================

EOF

}

if [[ "$1" != "-si" && "$1" != "-st" && "$1" != "-h" && "$1" != "-help" && "$1" != "-v" && "$1" != "--create-vpc" && "$1" != "-c" && "$1" != "--renew-certs" && "$1" != "-s" && "$1" != "--spinup" && "$1" != "-p" && "$1" != "--update-proxy" && "$1" != "-bs" && "$1" != "--provision-buildserver" && "$1" != "-ea" && "$1" != "--provision-erpagent" && "$1" != "-ba" && "$1" != "--provision-buildagent" && "$1" != "-br" && "$1" != "--provision-bastionserver" && "$1" != "-a" && "$1" != "--provision-controller" ]]; then
    printf "\e[31;1m syntax error \e[0m\n"
    exit
fi


while getopts ":n:" opt; do
 case $opt in
   n) input_instance_name="$OPTARG"
   ;;
 esac
done

if [[ "$1" == "-si" || "$1" == "-st" ]]; then
    if [[ -z "$input_instance_name" || "$input_instance_name" == "" ]]; then
    printf "\e[31;1m Instance name is empty \e[0m\n"
        exit
    fi
fi

if [[ -z "$input_instance_name" && -z "$1" ]]; then
    echo "Syntax error"
    exit
elif [ "$input_instance_name" = "$INSTANCE_NAME" ]; then
    echo "Not allowed to shutdown controller"
    exit
elif [ "$input_instance_name" != "$INSTANCE_NAME" ];
    then
  if [ "$1" = "-si" ]; then
    res1=$(start-instance)
    printf "$res1"
  elif [ "$1" = "-st" ];
    then
    res2=$(stop-instance)
    printf "$res2"
  fi
fi

case "$1" in
-u | --refresh-user)
    refresh-user
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

-a |--provision-controller)
    provision-controller
    ;;

-h | --help)
    display_help  # Call your function
    exit 0
    ;;
*)
    echo $"Usage: $0 {start-instance|stop-instance|refresh-user|provision-controller|bastion-server|create-vpc|renew-certs|spinup-instance|update-proxy|provison-buildserver|provision-erpagent|provision-buildagent|help}"
    exit 1
esac
