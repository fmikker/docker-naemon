#!/bin/bash

if [ ! -f ${NAEMON_HOME}/etc/htpasswd.users ] ; then
  htpasswd -c -b -s ${NAEMON_HOME}/etc/htpasswd.users ${NAEMONADMIN_USER} ${NAEMONADMIN_PASS}
  chown -R naemon.naemon ${NAEMON_HOME}/etc/htpasswd.users
fi

exec /usr/local/bin/cycle_notifications.sh 2>&1 > /var/log/notifications.log &
exec runsvdir /etc/sv

/etc/init.d/apache2 start
