#!/bin/bash
set -e
container_name=$container_name
sudo yum install -y docker
sudo chkconfig docker on
sudo service docker start
sudo docker login -u $hub_username -p $hub_password

if sudo semanage port -l |grep ${https_port}; then
   echo "Port already defined"
  else
  sudo semanage port --add --type http_port_t --proto tcp ${https_port}
fi

if sudo docker ps | grep ${container_name}; then
   sudo docker stop "${container_name}" | sudo xargs docker rm
else
  echo "Container not exists"
fi

if sudo docker ps | grep ${container_name}; then
   sudo docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo docker rm
else
  echo "Exit container not present"
fi

if sudo docker images | grep ${container_name}; then
   sudo docker rmi $(sudo docker images | grep ${container_name} | tr -s ' ' | cut -d ' ' -f 3)
else
  echo "Image doesn't exists"
fi

if ! sudo docker volume ls -q --filter name="${container_name}"| grep -q "${container_name}" ; then
        sudo docker volume create --name ${container_name}
else
        echo "Volume ${container_name} exists"
fi
sudo docker build --rm -t bahmni/bahmni_centos:${container_name} --build-arg rpm_version=${rpm_version} --build-arg inventory_name=${inventory_name} --build-arg aws_secret_key=${aws_secret_key} --build-arg container_name=${container_name} --build-arg aws_access_key=${aws_access_key} .
sudo docker run --restart=always -e container_name=${container_name} -it -d -p ${https_port}:443 --privileged --name $container_name -v $container_name:/$container_name bahmni/bahmni_centos:${container_name} /bin/bash
