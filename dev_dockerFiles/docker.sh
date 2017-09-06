#!/usr/bin/env bash
export container_name=container01
export rpm_version=0.90*
export inventory_name=aws_qa03
export https_port=443
export http_port=80
export erp_port=8069
export debug_port=8000

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
docker build --rm -t bahmni/bahmni_centos67 --build-arg rpm_version=${rpm_version} --build-arg inventory_name=${inventory_name} --build-arg container_name=${container_name} .
docker run -e container_name=${container_name} -it -d -p ${https_port}:443 -p ${http_port}:80 -p ${erp_port}:8069 -p ${debug_port}:8000 --privileged --name $container_name -v $container_name:/$container_name bahmni/bahmni_centos67 /bin/bash
