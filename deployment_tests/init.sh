#!/bin/bash

yum -y install ansible
yum -y install python-pip

pip install boto==2.43.0
pip install awscli
