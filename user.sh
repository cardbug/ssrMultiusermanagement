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

echo ""
echo '1.一键添加用户'
echo '2.添加用户'
echo '3.删除用户'
echo '4.修改用户'
echo '5.显示用户流量信息'
echo '6.显示用户名端口信息'
echo '7.查看端口用户连接状况'
echo '8.生成用户二维码'
echo "直接回车返回上级菜单"

while :; do echo
	read -p "请选择： " userc
        if [[ -z "$userc" ]];then  
                ssr
                break
        fi
	if [[ ! $userc =~ ^[1-8]$ ]]; then
		echo "输入错误! 请输入正确的数字!"
	else
		break	
	fi
done

if [[ $userc == 1 ]];then
	bash /usr/local/SSR-Bash-Python/user/easyadd.sh
	echo ""
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 2 ]];then
	bash /usr/local/SSR-Bash-Python/user/add.sh
	echo ""
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 3 ]];then
	bash /usr/local/SSR-Bash-Python/user/del.sh
	echo ""
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 4 ]];then
	bash /usr/local/SSR-Bash-Python/user/edit.sh
	echo ""
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 5 ]];then
	echo "1.使用用户名"
	echo "2.使用端口"
	echo ""
	while :; do echo
		read -p "请选择： " lsid
		if [[ ! $lsid =~ ^[1-2]$ ]]; then
			echo "输入错误! 请输入正确的数字!"
		else
			break	
		fi
	done
	if [[ $lsid == 1 ]];then
		read -p "输入用户名： " uid
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -l -u $uid
	fi
	if [[ $lsid == 2 ]];then
		read -p "输入端口号： " uid
		cd /usr/local/shadowsocksr
		python mujson_mgr.py -l -p $uid
	fi
	echo ""
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 6 ]];then
	P_V=`python -V 2>&1 | awk '{print $2}'`
	P_V1=`python -V 2>&1 | awk '{print $2}' | awk -F '.' '{print $1}'`
	if [[ ${P_V1} == 3 ]];then
		echo "你当前的python版本不支持此功能"
		echo "当前版本：${P_V} ,请降级至2.x版本"
	else
		python /usr/local/SSR-Bash-Python/user/show_all_user_info.py
	fi
	echo ""
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 7 ]];then
	read -p "请输入用户端口号:  " uid
	if [[ "$uid" =~ ^(-?|\+?)[0-9]+(\.?[0-9]+)?$ ]];then
		port=`netstat -anlt | awk '{print $4}' | sed -e '1,2d' | awk -F : '{print $NF}' | sort -n | uniq | grep "$uid"`
		if [[ -z ${port} ]];then
			echo "该端口号不存在"
			sleep 2s
			bash /usr/local/SSR-Bash-Python/user.sh
		else
			n=$(netstat -ntu | grep :${uid} | grep  "ESTABLISHED" | awk '{print $5}' | cut -d : -f 1 | sort -u | wc -l)
			echo -e "当前端口号 \e[41;37m${uid}\e[0m 共有 \e[42;37m${n}\e[0m 位用户连接"
			for ips in `netstat -ntu | grep :${uid} | grep  "ESTABLISHED" | awk '{print $5}' | cut -d : -f 1 | sort -u`
			do
				curl ip.cn/${ips}
			done
			echo "你可以输入IP地址，将其加入黑名单，这将不能撤销（按回车键返回）"
			while : 
			do
				read ip
				if [[ -z ${ip} ]];then
					break
				fi
				regex="\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\b"
				ckStep2=$(echo $ip | egrep $regex | wc -l)
				if [[ $ckStep2 -eq 0 ]];then
					echo "无效的ip地址"
					echo "请重新输入"
				else
					break
				fi
			done
			if [[ -z ${ip} ]];then
				bash /usr/local/SSR-Bash-Python/user.sh
				exit 0
			fi
			banip=$(iptables --list-rules | grep 'DROP' | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | grep "$ip")
			if [[ ! -z ${banip} ]];then
				echo "IP地址 ${ip} 已存在于禁封列表，请勿再次执行！"
				echo "当前封禁列表:"
				iptables --list-rules | grep 'DROP' | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort | uniq -c | sort -nr 
				bash /usr/local/SSR-Bash-Python/user.sh
				exit 0
			fi
			rsum=`date +%s%N | md5sum | head -c 6`
			echo -e "在下面输入\e[31;49m $rsum \e[0m表示您确定将IP：${ip}加入黑名单,这目前是不能恢复的"
			read -n 6 -p "请输入： " choise
			if [[ $choise == $rsum ]];then
				if [[ ${OS} =~ ^Ubuntu$|^Debian$ ]];then
					iptables-restore < /etc/iptables.up.rules
					iptables -A INPUT -s ${ip} -j DROP
					iptables-save > /etc/iptables.up.rules
				fi
				if [[ ${OS} == CentOS ]];then
					if [[ $CentOS_RHEL_version == 7 ]];then
						iptables-restore < /etc/iptables.up.rules
						iptables -A INPUT -s ${ip} -j DROP
						iptables-save > /etc/iptables.up.rules
					else
						iptables -A INPUT -s ${ip} -j DROP
						/etc/init.d/iptables save
						/etc/init.d/iptables restart
					fi
				fi
				echo "当前封禁列表:"
				iptables --list-rules | grep 'DROP' | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort | uniq -c | sort -nr
			else
				echo "输入错误"
				sleep 2s
			fi
		fi
	fi
	bash /usr/local/SSR-Bash-Python/user.sh
fi

if [[ $userc == 8 ]];then
	bash /usr/local/SSR-Bash-Python/user/qrcode.sh
	echo ""
	bash /usr/local/SSR-Bash-Python/user.sh
fi
exit 0
