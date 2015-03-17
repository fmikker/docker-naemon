#!/bin/bash

if (( $CYCLE_NOTIFICATIONS == 0 )); then
    exit 0
fi

CURL="/usr/bin/curl"
URL="http://localhost/nagios/cgi-bin/cmd.cgi"
NOTIFY_OFF=11
NOTIFY_ON=12
sleep $CYCLE_OFF_PAUSE
$CURL -d "cmd_mod=2&cmd_typ=${NOTIFY_OFF}" $URL -u "${NAGIOSADMIN_USER}:${NAGIOSADMIN_PASS}"
sleep $CYCLE_ON_PAUSE
$CURL -d "cmd_mod=2&cmd_typ=${NOTIFY_ON}" $URL -u "${NAGIOSADMIN_USER}:${NAGIOSADMIN_PASS}"

exit 0