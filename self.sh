#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

#Check OS
if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ];then
OS=CentOS
[ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
[ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
[ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ];then
OS=CentOS
CentOS_RHEL_version=6
elif [ -n "$(grep bian /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Debian' ];then
OS=Debian
[ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Deepin /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Deepin' ];then
OS=Debian
[ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Ubuntu /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Ubuntu' -o -n "$(grep 'Linux Mint' /etc/issue)" ];then
OS=Ubuntu
[ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
[ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
else
echo "Does not support this OS, Please contact the author! "
kill -9 $$
fi

#Main
updateme(){
	cd ~
	if [[ -e ~/version.txt ]];then
		rm -f ~/version.txt
	fi
	wget -q https://raw.githubusercontent.com/Readour/AR-B-P-B/develop/version.txt
	version1=`cat ~/version.txt`
	version2=`cat /usr/local/SSR-Bash-Python/version.txt`
	if [[ "$version1" == "$version2" ]];then
		echo "你当前已是最新版"
		sleep 2s
		ssr
	else
		echo "当前最新版本为$version1,输入y进行更新，其它按键退出"
		read -n 1 yn
		if [[ $yn == [Yy] ]];then
			wget -q -N --no-check-certificate https://raw.githubusercontent.com/Readour/AR-B-P-B/master/install.sh && bash install.sh develop
			sleep 3s
			clear
			ssr || exit 0
		else
			echo "输入错误，退出"
			bash /usr/local/SSR-Bash-Python/self.sh
		fi
	fi
}
sumdc(){
	sum1=`cat /proc/sys/kernel/random/uuid| cksum | cut -f1 -d" "|head -c 2`
	sum2=`cat /proc/sys/kernel/random/uuid| cksum | cut -f1 -d" "|head -c 1`
	solve=`echo "$sum1-$sum2"|bc`
	echo -e "请输入\e[32;49m $sum1-$sum2 \e[0m的运算结果,表示你已经确认,输入错误将退出"
	read sv
}
backup(){
	echo "开始备份!"
	mkdir -p ${HOME}/backup/tmp
	cd ${HOME}/backup/tmp
	cp /usr/local/shadowsocksr/mudb.json ./
	if [[ -e /usr/local/SSR-Bash-Python/check.log ]];then
		cp /usr/local/SSR-Bash-Python/check.log ./
	fi
	netstat -anlt | awk '{print $4}' | sed -e '1,2d' | awk -F : '{print $NF}' | sort -n | uniq >> ./port.conf
	wf=`ls | wc -l`
	if [[ $wf -ge 2 ]];then
		tar -zcvf ../ssr-conf.tar.gz ./*
	fi
	cd ..
	if [[ -e ./ssr-conf.tar.gz ]];then
		rm -rf ./tmp
		echo "备份成功,文件位于${HOME}/backup/ssr-conf.tar.gz"
	else
		echo "备份失败"
	fi
}
recover(){
echo "这将会导致你现有的配置被覆盖"
sumdc
if [[ "$sv" == "$solve" ]];then
	read -p "请输入备份文件的绝对路径(默认位于${HOME}/backup)：" bakfile
	if [[ -z ${bakfile} ]];then
		bakfile=${HOME}/backup
	fi
	if [[ -e ${bakfile}/ssr-conf.tar.gz ]];then
		cd $bakfile
		tar -zxvf ./ssr-conf.tar.gz
		if [[ -e ./check.log ]];then
			mv ./check.log /usr/local/SSR-Bash-Python/check.log
		fi
		if [[ ${OS} =~ ^Ubuntu$|^Debian$ ]];then
			iptables-restore < /etc/iptables.up.rules
			for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT ; done
			for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT ; done
			iptables-save > /etc/iptables.up.rules
			iptables -vnL
		fi
		if [[ ${OS} == CentOS ]];then
			if [[ $CentOS_RHEL_version == 7 ]];then
				iptables-restore < /etc/iptables.up.rules
				for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT ; done
				for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT ; done
				iptables-save > /etc/iptables.up.rules
				iptables -vnL
			else
				for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $port -j ACCEPT ; done 
				for port in `cat ./port.conf`; do iptables -I INPUT -m state --state NEW -m udp -p udp --dport $port -j ACCEPT ; done
				/etc/init.d/iptables save
				/etc/init.d/iptables restart
				iptables -vnL && sed -i '5a#tcp port rule' /etc/sysconfig/iptables
			fi
		fi
		rm -f /usr/local/shadowsocksr/mudb.json
		mv ./mudb.json /usr/local/shadowsocksr/mudb.json
		rm -f ./port.conf
		echo "还原操作已完成，开始检测是否已生效!"
		bash /usr/local/SSR-Bash-Python/servercheck.sh test
		if [[ -z ${SSRcheck} ]];then
			echo "配置已生效，还原成功"
		else
			echo "配置未生效，还原失败，请联系作者解决"
		fi
	else
		echo "备份文件不存在，请检查！"
	fi
else
	echo "计算错误，正确结果为$solve"
fi
}
#Show
echo "输入数字选择功能："
echo ""
echo "1.检查更新"
echo "2.切换到普通版"
echo "3.程序自检"
echo "4.卸载程序"
echo "5.备份配置"
echo "6.还原配置"
while :; do echo
	read -p "请选择： " choice
	if [[ ! $choice =~ ^[1-6]$ ]]; then
		[ -z "$choice" ] && ssr && break
		echo "输入错误! 请输入正确的数字!"
	else
		break	
	fi
done

if [[ $choice == 1 ]];then
	updateme
fi
if [[ $choice == 2 ]];then
	echo "切换到普通版之后你将无法使用一些功能"
	sumdc
	if [[ "$sv" == "$solve" ]];then
		wget -q -N --no-check-certificate https://raw.githubusercontent.com/Readour/AR-B-P-B/master/install.sh && bash install.sh
		sleep 3s
		clear
		ssr || exit 0
	else
		echo "计算错误，正确结果为$solve"
		bash /usr/local/SSR-Bash-Python/self.sh
	fi
fi
if [[ $choice == 3 ]];then
	bash /usr/local/SSR-Bash-Python/self-check.sh
fi
if [[ $choice == 4 ]];then
	echo "你在做什么？你真的这么狠心吗？"
	sumdc
	if [[ "$sv" == "$solve" ]];then
		wget -q -N --no-check-certificate https://raw.githubusercontent.com/Readour/AR-B-P-B/master/install.sh && bash install.sh uninstall
		exit 0
	else
		echo "计算错误，正确结果为$solve"
		bash /usr/local/SSR-Bash-Python/self.sh
	fi
fi
if [[ $choice == 5 ]];then
	if [[ ! -e ${HOME}/backup/ssr-conf.tar.gz ]];then
		backup
	else
		cd ${HOME}/backup
		mv ./ssr-conf.tar.gz ./ssr-conf-`date +%Y-%m-%d_%H:%M:%S`.tar.gz
		backup
	fi
	bash /usr/local/SSR-Bash-Python/self.sh
fi
if [[ $choice == 6 ]];then
	recover
	bash /usr/local/SSR-Bash-Python/self.sh
fi
exit 0