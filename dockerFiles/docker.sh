#!/bin/bash
set -e
image=$(docker images | awk '/<none>/ { print $3 }')
container_name=$container_name
sudo yum install -y docker
sudo chkconfig docker on
sudo service docker start
sudo docker login -u $hub_username -p $hub_password
sudo semanage port --add --type http_port_t --proto tcp $https_port

if sudo docker ps | grep -q ${container_name}; then
   sudo docker stop "${container_name}" && sudo docker rm -f "${container_name}" && docker rm $(docker ps -a -f status=exited -q)
   sudo docker rmi $(docker images | grep ${container_name} | awk '{print $3}')
else
  echo "Contianer not exists"
fi
if ! sudo docker volume ls -q --filter name="${container_name}"| grep -q "${container_name}" ; then
        sudo docker volume create --name ${container_name}
else
        echo "Volume ${container_name} exists"
fi
sudo docker build --rm -t senthilrajar/bahmni_centos:${container_name} --build-arg rpm_version=${rpm_version} --build-arg inventory_name=${inventory_name} --build-arg aws_secret_key=${aws_secret_key} --build-arg container_name=${container_name} --build-arg aws_access_key=${aws_access_key} .
sudo docker run -e container_name=${container_name} -it -d -p ${https_port}:443 --privileged --name $container_name -v $container_name:/$container_name senthilrajar/bahmni_centos:${container_name} /bin/bash
