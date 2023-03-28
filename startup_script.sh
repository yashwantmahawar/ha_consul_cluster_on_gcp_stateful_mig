#!/bin/bash
set -euxo pipefail

# install required utilities
sudo apt-get update -y
sudo apt-get install unzip -y
sudo apt-get install nftables -y

#bind disk
DISK_ID=/dev/disk/by-id/google-data-disk
MNT_DIR=/var/lib/consul
mkdir -p $MNT_DIR
if [[ $(lsblk $DISK_ID -no fstype) != 'ext4' ]]; then
          sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard $DISK_ID
else
    sudo e2fsck -fp $DISK_ID
    sudo resize2fs $DISK_ID
fi
if [[ ! $(grep -qs "$MNT_DIR " /proc/mounts) ]]; then
    if [[ ! $(grep -qs "$MNT_DIR " /etc/fstab) ]]; then
        UUID=$(blkid -s UUID -o value $DISK_ID)
        echo "UUID=$UUID $MNT_DIR ext4 discard,defaults,nofail 0 2" | sudo tee -a /etc/fstab
    fi
    systemctl daemon-reload
    sudo mount $MNT_DIR
fi

# Create consul user with home directory without login option
useradd -m consul --shell=/usr/sbin/nologin

# Create required directory
mkdir -p /var/lib/consul/conf.d
mkdir -p /opt/consul/${consul_version}/

# Install consul
cd /opt/consul/${consul_version}/
sudo curl -o consul.zip https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip
unzip consul.zip

# Create consol config file
echo '''
{
    "bind_addr": "0.0.0.0",
    "client_addr": "0.0.0.0",
    "server": true,
    "ui": true,
    "datacenter": "dc1",
    "data_dir": "/var/lib/consul",
    "encrypt": "UNhBPk2UCh6Tt7RdktxMmQ==",
    "log_level": "INFO",
    "enable_syslog": true,
    "leave_on_terminate": true,
    "bootstrap_expect" : 3,
    "retry_join": [ "provider=gce tag_value=consul-cluser-01 zone_pattern=asia-east1-.*" ]
}
''' | sudo tee /var/lib/consul/conf.d/default.json

# Create consul system service file
echo '''
[Unit]
Description=Consul Startup process
After=network.target
 
[Service]
Type=simple
User=consul
ExecStart=/bin/bash -c "/opt/consul/${consul_version}/consul agent --config-file=/var/lib/consul/conf.d/default.json -config-dir=/var/lib/consul/conf.d"
TimeoutStartSec=0
 
[Install]
WantedBy=default.target
''' | sudo tee /etc/systemd/system/consul.service

# Daemon reload
sudo systemctl daemon-reload

# Change the ownership to consul
chown -R consul:consul /var/lib/consul

sudo service consul restart

# Setup internal port forwarding 
echo '''
table ip dnsnat {
        chain prerouting {
                type nat hook prerouting priority dstnat; policy accept;
                udp dport 53 redirect to :8600
                tcp dport 53 redirect to :8600
        }
}''' | tee sudo /etc/nftables.conf
sudo nft flush ruleset
sudo service nftables restart
sudo nft list ruleset
sudo nft add table clouddns
sudo nft add chain clouddns postrouting {type filter hook postrouting priority 300\;}
sudo nft add rule clouddns postrouting ip saddr \
  $(curl -s -HMetadata-Flavor:Google metadata/computeMetadata/v1/instance/network-interfaces/0/ip) \
  udp sport 53 ip daddr 35.199.192.0/19 ip saddr set ${dns_static_ip}

set +x