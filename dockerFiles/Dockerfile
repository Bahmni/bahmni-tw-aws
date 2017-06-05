FROM bahmni/bahmni_centos67
ARG rpm_version
ARG inventory_name
ARG aws_access_key
ARG aws_secret_key
ARG container_name
VOLUME ["/$container_name"]
RUN echo -e "[bahmni] \nname=Bahmni development repository for RHEL/CentOS 6\nbaseurl=http://repo.mybahmni.org.s3-website-ap-southeast-1.amazonaws.com/rpm/bahmni/\nenabled=1\ngpgcheck=0\n" > /etc/yum.repos.d/bahmni.repo
RUN yum -y --enablerepo=extras install epel-release
RUN yum -y install python-pip git
RUN yum install -y sudo openssh-server openssh-clients tar wget yum-plugin-ovl  ; yum clean all
RUN pip install awscli
RUN pip install boto
RUN echo $rpm_version
RUN yum install -y bahmni-installer-$rpm_version-* ; yum clean all
RUN wget -O /etc/bahmni-installer/local https://raw.githubusercontent.com/Bahmni/bahmni-tw-playbooks/master/inventories/$inventory_name
RUN wget https://mirror.its.sfu.ca/mirror/CentOS-Third-Party/NSG/common/x86_64/jre-7u79-linux-x64.rpm -O /opt/jre-7u79-linux-x64.rpm 
RUN rpm -ivh /opt/jre-7u79-linux-x64.rpm
RUN yum install -y http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-centos92-9.2-7.noarch.rpm
RUN yum install -y yum install -y ftp://195.220.108.108/linux/Mandriva/devel/cooker/x86_64/media/contrib/release/mx-1.4.5-1-mdv2012.0.x86_64.rpm
RUN echo -e "selinux_state: disabled \npostgres_version: 9.2 \ntimezone: Asia/Kolkata \nimplementation_name: default \nbahmni_support_group: bahmni_support \nbahmni_support_user: bahmni_support \nbahmni_password_hash: $1$IW4OvlrH$Kui/55oif8W3VZIrnX6jL1 \nbahmni_repo_url: http://repo.mybahmni.org/rpm/bahmni/ \nopenerp_url: https://erp-$container_name.mybahmni.org \ndocker: yes " > /etc/bahmni-installer/setup.yml
RUN sed -i "1,100 s/^/#/" /opt/bahmni-installer/bahmni-playbooks/roles/dcm4chee-oracle-java/tasks/main.yml
RUN bahmni -ilocal install
RUN if [ -f "/etc/bahmni-certs/localhost.crt" ] then
    sudo rm -rf /etc/bahmni-certs/*
    sudo mkdir -p /opt/letsencrypt
    sudo git clone https://github.com/Bahmni/letsencrypt.git /opt/letsencrypt
    cd "/opt/letsencrypt"
    ansible-playbook -i infra_inventory letsencrypt.yml --extra-vars="aws_access_key=$aws_access_key" --extra-vars="aws_secret_key=$aws_secret_key" --extra-vars="container_name=$container_name" -vvv
    mkdir -p ${container_name}/letsencrypt
    Sudo cp -R /etc/letsencrypt-certs/* ${container_name}/letsencrypt/
    ln -s /${container_name}/letsencrypt/cert.crt /etc/bahmni-certs/cert
    ln -s /${container_name}/letsencrypt/chained.pem /etc/bahmni-certs/chained.pem
    ln -s /${container_name}/letsencrypt/domain.key /etc/bahmni-certs/domain.key
fi
ADD db_service.sh /tmp/db_service.sh
RUN chmod a+x /tmp/db_service.sh
#RUN git clone https://github.com/Bahmni/letsencrypt.git /opt/letsencrypt
#WORKDIR "/opt/letsencrypt"
#RUN ansible-playbook -i infra_inventory letsencrypt.yml --extra-vars="aws_access_key=$aws_access_key" --extra-vars="aws_secret_key=$aws_secret_key" --extra-vars="container_name=$container_name" -vvv
ENTRYPOINT /tmp/db_service.sh ; bahmni -ilocal start ; service bahmni-lab restart ; /bin/bash
