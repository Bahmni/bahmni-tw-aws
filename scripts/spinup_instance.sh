RED='\033[0;31m'
NC='\033[0m' # No Color
printf "${RED}Note: Spinup Instance ${NC}\n"

ansible-playbook -i ec2.py infra.yml -vvv
