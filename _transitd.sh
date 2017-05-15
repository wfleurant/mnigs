#!/usr/bin/env bash
##
# **Executed within container**
##

transitd_conf=/transitd/transitd.conf
transitd_path=/transitd/src/
transitd_logs=/var/log/transitd.log

if [ ! -f $transitd_conf ]; then
    echo "transitd: creating $transitd_conf"
    [ ! -f ${transitd_conf}.sample ] \
        && echo "transitd: missing ${transitd_conf}.sample" && exit

    cp ${transitd_conf}.sample ${transitd_conf} \
        && echo "transitd: created $transitd_conf" \
        || exit
fi

cd $transitd_path || exit

lua5.1 daemon.lua -f $transitd_conf > $transitd_logs 2>&1
