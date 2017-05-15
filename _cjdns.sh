#!/usr/bin/env bash
##
# **Executed within container**
##

cjdroute_exec=$(which cjdroute)
cjdroute_conf=/etc/cjdroute.conf
cjdroute_logs=/var/log/cjdns.log

if [ ! -f $cjdroute_conf ]; then
    $cjdroute_exec --genconf > $cjdroute_conf
fi

[ ! -f /etc/cjdroute.conf ] && echo "cjdroute: missing $cjdroute_conf" && exit

echo cjdroute: starting $(date) | tee $cjdroute_log
while :; do
    cat $cjdroute_conf | $cjdroute_exec --nobg
    echo cjdroute: restarting $(date) | tee -a $cjdroute_log
    sleep 1
done
