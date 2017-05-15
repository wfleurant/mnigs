#!/usr/bin/env bash
##
# **Executed within container**
##

transitd-cli --set "$( ip route | awk '/default/ { print "daemon.authorizedNetworks=127.0.0.1/8,::1/128," $3 }' )"
addr=$(hostname -i)
port="65533"

echo "cjdns: start-init"
bash /cjdns.sh &

echo "transitd: start-init"
sleep 3 # for tunnel interface enumerate
bash /transitd.sh &

echo "transitd: Web UI available at http://$addr:$port"
echo "transitd: Additional information 'transitd-cli -h'"

transitd-cli -h

echo

bash
