RED='\033[0;31m'
NC='\033[0m' # No Color
printf "${RED}Note: Deleting SSH User ${NC}\n"

ansible-playbook -i ec2.py all.yml -t manage_user -vvv