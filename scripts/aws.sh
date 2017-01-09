#!/bin/bash
TEMP_SCRIPT_DIR=`dirname -- "$0"`
SCRIPT_DIR=`cd $TEMP_SCRIPT_DIR; pwd`
cd $SCRIPT_DIR/..
INVENTORY="inventory/"
PROVISION="provision.yml"
VPC="vpc.yml"
CREATE_INSTANCE="create_instance.yml"
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
   ansible-playbook -i $INVENTORY $CREATE_INSTANCE -vvv

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

function provision-bahmniserver
{
   echo -e "\033[01;35m---------- Provision-Bahmniserver ----------"
   ansible-playbook -i $INVENTORY $PROVISION -t provision_bahmni_server -vvv

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

    -d, --provision-buildserver     Provision CI Server
    -e, --provision-erpagent        Provision ERP Agent
    -g, --provision-buildagent      Provision Build Agent
    -b, --provision-bastionserver   Provision Bastion Server
    -a, --provision-controller      Provision Ansible controller
    -m, --provision-bahmniserver   Provision bahmni-server
    -n                              Instance name
    -t, -start                      Start instance
    -r, -stop                       Stop instance
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

   Provision Build Server (-d, --provision-buildserver) : To install and configure new GoServer, "aws.sh -d".

   Provision Erpagent (-e, --provision-erpagent) : To install and configure ERP build agent, "aws.sh -e".

   Provision Build agent (-g, --provision-buildagent) : To install and configure build agent, "aws.sh -g".

   Provision Bastion Server ( -b, --provision-bastionserver) : To install and configure Bastion Server, "aws.sh -b".

   Provision Controller (-a, --provision-controller ) : To provision ansible controller box, "aws.sh -a".

   Instance name (-n )  : -n is used to start "aws.sh -t -n <instance name>" or stop "aws.sh -r -n <instance name>" specific instance.

   Start instance : To start instance "aws.sh -t -n <instance name>" or "aws.sh -start -n <instance name>"

   Stop instance : To stop instance "aws.sh -r -n <instance name>" or "aws.sh -stop -n <instance name>"

   =====================================================================================================================

EOF

}

if [[ "$1" != "-m" && "$1" != "--provision-bahmniserver" && "$1" != "-t" && "$1" != "-start" && "$1" != "-r" && "$1" != "-stop" && "$1" != "-h" && "$1" != "-help" && "$1" != "-v" && "$1" != "--create-vpc" && "$1" != "-c" && "$1" != "--renew-certs" && "$1" != "-s" && "$1" != "--spinup" && "$1" != "-p" && "$1" != "--update-proxy" && "$1" != "-d" && "$1" != "--provision-buildserver" && "$1" != "-e" && "$1" != "--provision-erpagent" && "$1" != "-g" && "$1" != "--provision-buildagent" && "$1" != "-b" && "$1" != "--provision-bastionserver" && "$1" != "-a" && "$1" != "--provision-controller" && "$1" != "-u" && "$1" != "--refresh-users" ]]; then
    printf "\e[31;1m syntax error \e[0m\n"
    exit
fi


while getopts ":n:" opt; do
 case $opt in
   n) input_instance_name="$OPTARG"
   ;;
 esac
done

if [[ "$1" == "-t" || "$1" == "-start" || "$1" == "-r" || "$1" == "-stop" ]]; then
    if [[ -z "$input_instance_name" || "$input_instance_name" == "" ]]; then
    printf "\e[31;1m Instance name is empty \e[0m\n"
        exit
    fi
fi

if [[ -z "$input_instance_name" && -z "$1" ]]; then
    echo "Syntax error"
    exit
elif [ "$input_instance_name" = "$INSTANCE_NAME" ]; then
     printf "\e[31;1m Not allowed to shutdown controller \e[0m\n"
    exit
elif [ "$input_instance_name" != "$INSTANCE_NAME" ];
    then
  if [[ "$1" = "-t" || "$1" = "-start" ]]; then
    printf "\e[1;32m Start '"$input_instance_name"' instance \e[0m"
    result=$(start-instance)
    printf "$result"
  elif [[ "$1" = "-r" || "$1" = "-stop" ]];
    then
    printf "\e[1;32m Stop '"$input_instance_name"' instance \e[0m"
    result=$(stop-instance)
    printf "$result"
  fi
fi

case "$1" in
-u | --refresh-users)
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
-d |--provision-buildserver)
    provision-build-server
    ;;
-e |--provision-erpagent)
    provision-erpagent
    ;;
-g |--provision-buildagent)
    provision-buildagent
    ;;
-b |--provision-bastionserver)
    bastion-server
    ;;

-a |--provision-controller)
    provision-controller
    ;;
-m |--provision-bahmniserver)
    provision-bahmniserver
    ;;

-h | --help)
    display_help  # Call your function
    exit 0
    ;;
*)
    exit 1
esac
