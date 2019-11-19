#!/bin/bash
echo "Prepare the system"
echo "  - Adding current SSH key to authorized_keys"
sudo su vagrant -c 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'
echo "  - Adding me to /etc/hosts"
echo "192.168.159.11	me" >> /etc/hosts
echo "  - Disabling selinux"
echo "SELINUX=permisive" > /etc/selinux/config
echo "SELINUXTYPE=targeted" >> /etc/selinux/config
setenforce 0
echo "  - Give nginx deamon access to vagrant user's files"
chmod go+rx /home/vagrant
echo "  - Overwrite sudoers for vagrant"
rm /etc/sudoers && wget -O /etc/sudoers https://s3.eu-central-1.amazonaws.com/cig-exchange.ch/sudoers
echo "      - Change sudoers permission"
chmod go-rwx /etc/sudoers
cd /home/vagrant
usermod -aG wheel vagrant
echo "ClientAliveInterval 0" >> /etc/ssh/sshd_config
echo "TCPKeepAlive no" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 240" >> /etc/ssh/sshd_config

# Install PostgreSQL
echo "Install PostgreSQL"
yum update && yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum-config-manager --enable pgdg12
yum install -y postgresql12 postgresql12-server
/usr/pgsql-12/bin/postgresql-12-setup initdb
systemctl enable postgresql-12


# Install GoLang
echo "Install GoLang"
wget https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz &>/dev/null
tar -C /usr/local -xzf go1.13.4.linux-amd64.tar.gz
rm go1.13.4.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/bin:/usr/local/go/bin" >> /etc/profile

# Install Redis
echo "Install Redis"
yum install redis -y
systemctl enable redis
echo "bind 0.0.0.0" > /etc/redis.conf
echo "protected-mode no" >> /etc/redis.conf
systemctl enable redis

# Install nodejs, yarn and dredd
echo "Install nodejs yarn and dredd"
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
yum install -y nodejs
# Install latest yarn
echo "Installing Yarn"
curl --compressed -o- -L https://yarnpkg.com/install.sh | sudo su vagrant -c 'bash'
sudo su vagrant -c '~/.yarn/bin/yarn global add dredd'

# Add bind volume for Nginx
echo "Install Nginx"
yum install -y nginx
mkdir -p /var/www/html

# Add all necessary package for UI test
yum install -y pango libXcomposite libXcursor libXdamage libXext libXi libXtst cups-libs libXScrnSaver libXrandr GConf2 alsa-lib atk gtk3 ipa-gothic-fonts xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-utils xorg-x11-fonts-cyrillic xorg-x11-fonts-Type1 xorg-x11-fonts-misc firefox chromium

