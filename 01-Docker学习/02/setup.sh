#/bin/sh

# install some tools
sudo yum install -y git vim gcc glibc-static telnet bridge-utils

# install docker
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh

# start docker service
sudo groupadd docker
# 命令不用输入 sudo
sudo usermod -aG docker vagrant
sudo systemctl start docker

rm -rf get-docker.sh
