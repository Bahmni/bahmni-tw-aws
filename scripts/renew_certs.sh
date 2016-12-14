RED='\033[0;31m'
NC='\033[0m' # No Color
printf "${RED}Note: Renew Certificates ${NC}\n"

ansible-playbook -i ec2.py provision.yml -t renew_certs -vvv