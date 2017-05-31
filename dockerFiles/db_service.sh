#!/bin/bash
set -e

if (( $(ps -ef | grep -v grep | grep mysqld | wc -l) > 0 ))
then
echo "mysqld is running"
else
sudo service mysqld start
fi

sudo service postgresql-9.2 status
if [ "$?" -gt "0" ]; then
  echo "Not installed".
else
  sudo service postgresql-9.2 start
fi
