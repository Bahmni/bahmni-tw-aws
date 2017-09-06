FROM bahmni/bahmni_centos67
ARG rpm_version
ARG inventory_name
ARG container_name
ARG erp_port
VOLUME ["/$container_name"]
RUN echo -e "[bahmni] \nname=Bahmni development repository for RHEL/CentOS 6\nbaseurl=http://repo.mybahmni.org.s3-website-ap-southeast-1.amazonaws.com/rpm/bahmni/\nenabled=1\ngpgcheck=0\n" > /etc/yum.repos.d/bahmni.repo
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
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
RUN echo -e "selinux_state: disabled \npostgres_version: 9.2 \ntimezone: Asia/Kolkata \nimplementation_name: default \nbahmni_support_group: bahmni_support \nbahmni_support_user: bahmni_support \nbahmni_password_hash: $1$IW4OvlrH$Kui/55oif8W3VZIrnX6jL1 \nbahmni_repo_url: http://repo.mybahmni.org/rpm/bahmni/ \nopenerp_url: http://127.0.0.1:8069 \ndocker: yes " > /etc/bahmni-installer/setup.yml
RUN sed -i "1,100 s/^/#/" /opt/bahmni-installer/bahmni-playbooks/roles/dcm4chee-oracle-java/tasks/main.yml
RUN bahmni -ilocal install
ADD db_startup_script.sh /tmp/db_startup_script.sh
RUN chmod a+x /tmp/db_startup_script.sh
ENTRYPOINT /tmp/db_startup_script.sh ; bahmni -ilocal start ; service bahmni-lab restart ; sh /tmp/db_startup_script.sh ; /bin/bash
