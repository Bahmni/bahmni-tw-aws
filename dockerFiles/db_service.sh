#!/bin/bash
set -e

ps cax | grep mysqld > /dev/null
if [ $? -eq 0 ]; then
  echo "mysqld service exists"
  sudo service mysqld start
else
  echo "mysqld service not exists"
fi

sudo service postgresql-9.2 status

if [ "$?" -gt "0" ]; then
  echo "Not installed".
else
  sudo service postgresql-9.2 start
fi
