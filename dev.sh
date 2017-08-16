#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

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

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

echo "测试区域，请勿随意使用"
echo "1.更新SSR-Bsah"
echo "2.一键封禁BT下载，SPAM邮件流量（无法撤销）"
echo "3.防止暴力破解SS连接信息 (重启后失效)"
echo "4.布署ss-panel(有风险!)"
echo "5.BBR 控制台"
while :; do echo
	read -p "请选择： " devc
	[ -z "$devc" ] && ssr && break
	if [[ ! $devc =~ ^[1-5]$ ]]; then
		echo "输入错误! 请输入正确的数字!"
	else
		break	
	fi
done

if [[ $devc == 1 ]];then
	rm -rf /usr/local/bin/ssr
	cd /usr/local/SSR-Bash-Python/
	git pull
	wget -N --no-check-certificate -O /usr/local/bin/ssr https://raw.githubusercontent.com/readour/AR-B-P-B/develop/ssr
	chmod +x /usr/local/bin/ssr
	echo 'SSR-Bash升级成功！'
	ssr
fi

if [[ $devc == 2 ]];then
	wget -4qO- softs.pw/Bash/Get_Out_Spam.sh|bash
fi

if [[ $devc == 3 ]];then
	nohup tail -F /usr/local/shadowsocksr/ssserver.log | python autoban.py >log 2>log &
fi

if [[ $devc == 4 ]];then
	rsum=`date +%s%N | md5sum | head -c 6`
	echo "您即将部署ss-panel，整个过程时间较长，并且存在风险（您原来的web将无法使用）"
	echo -e "在下面输入\e[31;49m $rsum \e[0m表示您已知晓风险并同意安装，输入其它内容将退出安装！"
	read -n 6 -p "请输入： " choise
	if [[ $choise == $rsum ]];then
		cd /usr/local/SSR-Bash-Python
		if [ ! -e ./sspanel.sh ];then
			echo "您已安装过ss-panel，无需重复安装"
			sleep 2s
			ssr
		else
			bash ./sspanel.sh 
			exit 0
		fi
	else
		echo "输入错误，安装退出！"
		sleep 2s
		ssr
	fi
fi
bbrcheck(){
cd /usr/local/SSR-Bash-Python
if [[ ! -e bbr.sh ]]; then
	echo "没有发现 BBR脚本，开始下载..."
	if ! wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/bbr.sh; then
		echo "BBR 脚本下载失败 !" && exit 1
	else
		echo "BBR 脚本下载完成 !"
		chmod +x bbr.sh
	fi
fi
}
if [[ $devc == 5 ]];then 
	[[ $OS = "CentOS" ]] && echo "本脚本不支持 CentOS系统 BBR !" && ssr
	echo "你要做什么？"
	echo "1.安装 BBR"
	echo "————————"
	echo "2.启动 BBR"
	echo "3.停止 BBR"
	echo "4.查看 BBR 状态"
	echo ""
	while :; do echo
	read -p "请选择： " ubbr
	[ -z "$ubbr" ] && ssr && break
	if [[ ! $ubbr =~ ^[1-4]$ ]]; then
		echo "输入错误! 请输入正确的数字!"
	else
		break	
	fi
	done
	if [[ $ubbr == 1 ]];then
		rsum=`date +%s%N | md5sum | head -c 6`
		echo " [安装前 请注意]"
		echo "1. 安装开启BBR，需要更换内核，存在更换失败等风险(重启后无法开机)"
		echo "2. 本脚本仅支持 Debian / Ubuntu 系统更换内核，OpenVZ和Docker 不支持更换内核"
		echo "3. Debian 更换内核过程中会提示 [ 是否终止卸载内核 ] ，请选择 NO "
		echo ""
		echo -e "在下面输入\e[31;49m $rsum \e[0m表示您已知晓风险并同意安装，输入其它内容将退出安装！"
		read -n 6 -p "请输入： " choise
		if [[ $choise == $rsum ]];then
			bbrcheck
			bash bbr.sh
		else
			echo "输入错误，安装退出！"
			sleep 2s
			ssr
		fi
	fi
	if [[ $ubbr == 2 ]];then
		bbrcheck
		bash bbr.sh start
	fi
	if [[ $ubbr == 3 ]];then
		bbrcheck
		bash bbr.sh stop
	fi
	if [[ $ubbr == 4 ]];then
		bbrcheck
		bash bbr.sh status
	fi
fi
