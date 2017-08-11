#!/bin/bash
#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

install_ss_panel(){
	#check OS version
	check_sys(){
		if [[ -f /etc/redhat-release ]]; then
			release="centos"
		elif cat /etc/issue | grep -q -E -i "debian"; then
			release="debian"
		elif cat /etc/issue | grep -q -E -i "ubuntu"; then
			release="ubuntu"
		elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
			release="centos"
		elif cat /proc/version | grep -q -E -i "debian"; then
			release="debian"
		elif cat /proc/version | grep -q -E -i "ubuntu"; then
			release="ubuntu"
		elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
			release="centos"
	    fi
		bit=`uname -m`
	}
	install_soft_for_each(){
		check_sys
		if [[ ${release} = "centos" ]]; then
			yum install -y unzip zip
			yum install git -y
		else
			sudo apt-get install zip
			apt-get update -y
			apt-get install git -y
		fi
	}
	install_soft_for_each
	wget -c https://raw.githubusercontent.com/mmmwhy/ss-panel-and-ss-py-mu/master/lnmp1.3.zip && unzip lnmp1.3.zip && cd lnmp1.3 && chmod +x install.sh && ./install.sh lnmp
	chattr -i /home/wwwroot/default/.user.ini
	rm -rf /home/wwwroot/default
	git clone https://github.com/readour/ss-panel.git "/home/wwwroot/default"
	cd /home/wwwroot/default
	git checkout v3
	curl -sS https://install.phpcomposer.com/installer | php
	chmod +x composer.phar
	php composer.phar install
	chmod -R 777 storage
	mysql -uroot -proot -e"create database ss;" 
	mysql -uroot -proot -e"use ss;" 
	mysql -uroot -proot ss < /home/wwwroot/default/db.sql
	wget -N -P  /usr/local/nginx/conf/ https://raw.githubusercontent.com/zyh001/zyh001.github.com/master/nginx.conf
	lnmp nginx restart
}

install_ss_panel
IPAddress=`wget http://members.3322.org/dyndns/getip -O - -q ; echo`;

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

echo -e "modify Config.py...\n"
sed -i "s#domain#${IPAddress}#" /usr/local/shadowsocksr/shadowsocks/config.py
echo_supervisord_conf > /etc/supervisord.conf
sed -i '$a [program:ss-manyuser]\ncommand = python /usr/local/shadowsocksr/shadowsocks/servers.py\nuser = root\nautostart = true\nautorestart = true' /etc/supervisord.conf
supervisord
systemctl stop firewalld.service
systemctl disable firewalld.service
yum install iptables-services -y
iptables -I INPUT -p tcp -m tcp --dport 104 -j ACCEPT
iptables -I INPUT -p udp -m udp --dport 104 -j ACCEPT
iptables -I INPUT -p tcp -m tcp --dport 1024: -j ACCEPT
iptables -I INPUT -p udp -m udp --dport 1024: -j ACCEPT
iptables-save >/etc/sysconfig/iptables
echo 'iptables-restore /etc/sysconfig/iptables' >> /etc/rc.local
echo "/usr/bin/supervisord -c /etc/supervisord.conf" >> /etc/rc.local
chmod +x /etc/rc.d/rc.local
sleep 4
cat shadowsocks.log
echo ""
echo "#############################################################"
echo "# 安装完成，登录http://${IPAddress}看看吧~                  #"
echo "# Github: https://github.com/mmmwhy/ss-panel-and-ss-py-mu   #"
echo "# Author: 91vps                                             #"
echo "# Blog: https://91vps.club/2017/05/26/ss-panel/             #"
echo "#############################################################"
exit 0