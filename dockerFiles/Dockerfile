FROM bahmni/bahmni-centos69
ARG rpm_version
ARG inventory_name
ARG aws_access_key
ARG aws_secret_key
ARG container_name
VOLUME ["/$container_name"]
RUN echo -e "[bahmni] \nname=Bahmni development repository for RHEL/CentOS 6\nbaseurl=http://repo.mybahmni.org.s3-website-ap-southeast-1.amazonaws.com/rpm/bahmni/\nenabled=1\ngpgcheck=0\n" > /etc/yum.repos.d/bahmni.repo \
    && rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm \
    && yum -y install epel-release python-pip git \
    && yum install -y sudo openssh-server openssh-clients tar wget yum-plugin-ovl  ; yum clean all \
    && pip install awscli \
    && pip install boto \
    && yum upgrade python-setuptools \
    && yum install -y bahmni-installer-$rpm_version-* \
    && wget -O /etc/bahmni-installer/local https://raw.githubusercontent.com/Bahmni/bahmni-tw-playbooks/master/inventories/$inventory_name \
    && wget https://mirror.its.sfu.ca/mirror/CentOS-Third-Party/NSG/common/x86_64/jre-7u79-linux-x64.rpm -O /opt/jre-7u79-linux-x64.rpm \
    && rpm -ivh /opt/jre-7u79-linux-x64.rpm \
    && yum install -y http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-centos92-9.2-7.noarch.rpm \
    && yum install -y ftp://195.220.108.108/linux/Mandriva/devel/cooker/x86_64/media/contrib/release/mx-1.4.5-1-mdv2012.0.x86_64.rpm \
    && sed -i "1,100 s/^/#/" /opt/bahmni-installer/bahmni-playbooks/roles/dcm4chee-oracle-java/tasks/main.yml \
    && pip uninstall -y docutils
ADD setup.yml /etc/bahmni-installer/setup.yml
RUN bahmni -ilocal install
RUN if [[ -f "/${container_name}/letsencrypt/cert.crt" && -f "/${container_name}/letsencrypt/chained.pem" && -f "/${container_name}/letsencrypt/domain.key" ]] && openssl x509 -checkend 86400 -noout -in "/${container_name}/letsencrypt/chained.pem" ; then \
	echo "inside if" ;\
    rm -rf /etc/bahmni-certs/* ;\
    ln -s /${container_name}/letsencrypt-certs/cert.crt /etc/bahmni-certs/cert;\
    ln -s /${container_name}/letsencrypt-certs/chained.pem /etc/bahmni-certs/chained.pem;\
    ln -s /${container_name}/letsencrypt-certs/domain.key /etc/bahmni-certs/domain.key;\
else \
	echo "inside else" ;\
	sudo rm -rf /opt/letsencrypt ;\
	sudo mkdir -p /opt/letsencrypt ;\
    sudo git clone https://github.com/Bahmni/letsencrypt.git /opt/letsencrypt ;\
    cd "/opt/letsencrypt" ;\
    ansible-playbook -i infra_inventory letsencrypt.yml --extra-vars="aws_access_key=$aws_access_key" --extra-vars="aws_secret_key=$aws_secret_key" --extra-vars="container_name=$container_name" -vvv ;\
rm -rf /etc/bahmni-certs/* ;\
sudo ln -s /${container_name}/letsencrypt-certs/cert.crt /etc/bahmni-certs/cert.crt ;\
sudo ln -s /${container_name}/letsencrypt-certs/chained.pem /etc/bahmni-certs/chained.pem ;\
sudo ln -s /${container_name}/letsencrypt-certs/domain.key /etc/bahmni-certs/domain.key ;\
fi 
ADD db_service.sh /tmp/db_service.sh
RUN chmod a+x /tmp/db_service.sh
ENTRYPOINT /tmp/db_service.sh ; bahmni -ilocal start ; service bahmni-lab restart ; /bin/bash
