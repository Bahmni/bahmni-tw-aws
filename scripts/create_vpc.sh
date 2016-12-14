RED='\033[0;31m'
NC='\033[0m' # No Color
printf "${RED}Note: Creating Virtual Private Cloud ${NC}\n"

ansible-playbook -i infra_inventory vpc.yml -vvv
