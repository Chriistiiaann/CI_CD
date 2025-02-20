#!/bin/bash
exec > /tmp/beforeinstall.log 2>&1

apt update -y
apt upgrade -y
apt install -y openjdk-21-jdk python3-pip ruby-full wget git

pip3 install https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-py3-latest.tar.gz

ln -s /usr/local/init/ubuntu/cfn-hup /etc/init.d/cfn-hup

sudo sed -i 's/^\$nrconf{restart} = "i";/\$nrconf{restart} = "a";/' /etc/needrestart/needrestart.conf
sudo sed -i 's/^\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/' /etc/needrestart/needrestart.conf
sudo sed -i 's/^\$nrconf{checks} = 1;/\$nrconf{checks} = 0;/' /etc/needrestart/needrestart.conf