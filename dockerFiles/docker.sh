#!/bin/bash
set -e
container_name=$container_name
sed -i '1i \'$ansible_vault_key'\' /var/go/.keys/bahmni-tw-aws.pem
sed -i '2d' /var/go/.keys/bahmni-tw-aws.pem
sudo yum install -y docker
sudo chkconfig docker on
sudo service docker start
sudo docker login -u $hub_username -p $hub_password
if [ "${imgs}" != "" ]; then
   sudo docker images | grep "<none>" | awk '{print $3}' | xargs docker rmi
else
   echo "No images to remove"
fi
if sudo docker ps | awk -v container_name="${container_name}" 'NR>1{($(NF) == container_name)}'; then
   sudo docker stop "${container_name}" && sudo docker rm -f "${container_name}"
fi
cd ${base_path}/${GO_PIPELINE_NAME}/bahmni-tw-aws
ansible-playbook -i inventory/ docker_instance.yml  --extra-vars="container_name=$container_name" --extra-vars="https_port=$https_port"  --extra-vars="erp_port=$erp_port" -vvv
cd ..
sudo docker build -t senthilrajar/bahmni_centos:${rpm_version} --build-arg rpm_version=${rpm_version} --build-arg aws_secret_key=${aws_secret_key} --build-arg container_name=${container_name} --build-arg aws_access_key=${aws_access_key} .
sudo docker run -it -d -p ${https_port}:443 -p ${erp_port}:8069 --privileged --name $container_name senthilrajar/bahmni_centos:${rpm_version} /bin/bash
