#!/bin/bash
set -e
container_name=$container_name
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
if ! sudo docker volume ls -q --filter name="${container_name}"| grep -q "${container_name}" ; then
        sudo docker volume create ${container_name}
else
        echo "Volume ${container_name} exists"
fi
sudo docker build -t senthilrajar/bahmni_centos:${rpm_version} --build-arg rpm_version=${rpm_version} --build-arg inventory_name=${inventory_name} --build-arg aws_secret_key=${aws_secret_key} --build-arg container_name=${container_name} --build-arg aws_access_key=${aws_access_key} .
sudo docker run -it -d -p ${https_port}:443 --privileged --name $container_name -v $container_name:/$container_name senthilrajar/bahmni_centos:${rpm_version} /bin/bash
