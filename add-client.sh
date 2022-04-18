#!/bin/bash

#!/bash
if [ $# -eq 0 ]
then
        echo "При запуске скрипта необходимо указать имя клиента: add_client.sh new-client"
else
        echo "Creating client config for: $1"
        wg genkey | tee $1.priv | wg pubkey > $1.pub
        key=$(cat $1.priv)
        ip_serv_ext=$(wget -qO- ipinfo.io/ip)
        ip="170.21.0."$(expr $(cat last-ip.txt | tr "." " " | awk '{print $4}') + 1)
        SERVER_PUB_KEY=$(cat public_vpa.key)
        cat wg0-client.example.conf | sed -e 's/:CLIENT_IP:/'"$ip"'/' | sed -e 's|:CLIENT_KEY:|'"$key"'|' | sed -e 's|:SERVER_PUB_KEY:|'"$SERVER_PUB_KEY"'|' | sed -e 's|:SERVER_ADDRESS:|'"$ip_serv_ext"'|' > $1.conf
        echo $ip > last-ip.txt
        echo "Created config!"
        echo "Adding peer"
        sudo wg set wg0 peer $(cat $1.pub) allowed-ips $ip/32
        echo "Adding peer to hosts file"
        echo $ip" "$1 | sudo tee -a /etc/hosts
        sudo wg show
        echo "[Peer]
#$1
PublicKey = $key
AllowedIPs = $ip/32" | sudo tee -a /etc/wireguard/wg0.conf
rm -f $1.pub
rm -f $1.priv
qrencode -t ansiutf8 < $1.conf
fi
