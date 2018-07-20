FROM bahmni/bahmni_centos67
ARG rpm_version
ARG inventory_name
ARG container_name
ARG erp_port
VOLUME ["/$container_name"]
RUN echo -e "[bahmni] \nname=Bahmni development repository for RHEL/CentOS 6\nbaseurl=http://repo.mybahmni.org.s3-website-ap-southeast-1.amazonaws.com/rpm/bahmni/\nenabled=1\ngpgcheck=0\n" > /etc/yum.repos.d/bahmni.repo \
    && rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm \
    && yum install -y sudo git openssh-server openssh-clients tar wget yum-plugin-ovl bahmni-installer-$rpm_version-* ; yum clean all \
    && wget -O /etc/bahmni-installer/local https://raw.githubusercontent.com/Bahmni/bahmni-tw-playbooks/master/inventories/$inventory_name \
    && yum install -y yum install -y ftp://195.220.108.108/linux/Mandriva/devel/cooker/x86_64/media/contrib/release/mx-1.4.5-1-mdv2012.0.x86_64.rpm \
    && echo -e "selinux_state: disabled \npostgres_version: 9.2 \ntimezone: Asia/Kolkata \nimplementation_name: default \nbahmni_support_group: bahmni_support \nbahmni_support_user: bahmni_support \nbahmni_password_hash: $1$IW4OvlrH$Kui/55oif8W3VZIrnX6jL1 \nbahmni_repo_url: http://repo.mybahmni.org/rpm/bahmni/ \nopenerp_url: http://127.0.0.1:8069 \ndocker: yes " > /etc/bahmni-installer/setup.yml \
    && sed -i "1,100 s/^/#/" /opt/bahmni-installer/bahmni-playbooks/roles/dcm4chee-oracle-java/tasks/main.yml
RUN bahmni -ilocal install
ADD db_startup_script.sh /tmp/db_startup_script.sh
RUN chmod a+x /tmp/db_startup_script.sh
ENTRYPOINT /tmp/db_startup_script.sh ; bahmni -ilocal start ; service bahmni-lab restart ; sh /tmp/db_startup_script.sh ; /bin/bash