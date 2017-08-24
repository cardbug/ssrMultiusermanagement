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
echo "6.锐速 控制台"
echo "7.LotServer 控制台"
echo "8.UML-LKL(OpenVZ-BBR)安装"
while :; do echo
	read -p "请选择： " devc
	[ -z "$devc" ] && ssr && break
	if [[ ! $devc =~ ^[1-8]$ ]]; then
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
	#代码来自：https://91vps.us/2017/08/24/ss-panel-v3-mod/
	rsum=`date +%s%N | md5sum | head -c 6`
	echo "您即将部署ss-panel，整个过程时间较长，并且存在风险,请保证你的系统纯净"
	echo "为避免意外断线导致安装中断，推荐在screen中运行"
	echo "安装脚本非本人所写，来源：https://github.com/mmmwhy/ss-panel-and-ss-py-mu/blob/master/ss-panel-v3-mod.sh"
	echo "默认账号：ss@feiyang.li    默认密码：feiyang"
	echo -e "在下面输入\e[31;49m $rsum \e[0m表示您已知晓风险并同意安装，输入其它内容将退出安装！"
	read -n 6 -p "请输入： " choise
	if [[ $choise == $rsum ]];then
		wget -q -N --no-check-certificate https://raw.githubusercontent.com/mmmwhy/ss-panel-and-ss-py-mu/master/ss-panel-v3-mod.sh && chmod +x ss-panel-v3-mod.sh && bash ss-panel-v3-mod.sh
	else
		echo "输入错误，安装退出！"
		sleep 2s
		ssr
	fi
fi
bbrcheck(){
cd /usr/local/SSR-Bash-Python
#GitHub:https://github.com/ToyoDAdoubi
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
	[[ $OS = "CentOS" ]] && echo "本脚本不支持 CentOS系统 BBR !" && exit 1
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
install_rz(){
	[[ -e /serverspeeder/bin/serverSpeeder.sh ]] && echo "锐速(Server Speeder) 已安装 !" && ssr
	cd /usr/local/SSR-Bash-Python
	#借用91yun.rog的开心版锐速
	wget -N --no-check-certificate https://raw.githubusercontent.com/91yun/serverspeeder/master/serverspeeder.sh
	[[ ! -e "serverspeeder.sh" ]] && echo "锐速安装脚本下载失败 !" && ssr
	bash serverspeeder.sh
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "serverspeeder" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		rm -rf /usr/local/SSR-Bash-Python/serverspeeder.sh
		rm -rf /usr/local/SSR-Bash-Python/91yunserverspeeder
		rm -rf /usr/local/SSR-Bash-Python/91yunserverspeeder.tar.gz
		echo "锐速(Server Speeder) 安装完成 !" && exit 0
	else
		echo "锐速(Server Speeder) 安装失败 !" && exit 1
	fi
}
if [[ $devc == 6 ]];then
	echo "你要做什么？"
	echo "1.安装 锐速"
	echo "2.卸载 锐速"
	echo "————————"
	echo "3.启动 锐速"
	echo "4.停止 锐速"
	echo "5.重启 锐速"
	echo "6.查看 锐速 状态"
	echo "注意： 锐速和LotServer不能同时安装/启动！"
	while :; do echo
	read -p "请选择： " urz
	[ -z "$urz" ] && ssr && break
	if [[ ! $urz =~ ^[1-6]$ ]]; then
		echo "输入错误! 请输入正确的数字!"
	else
		break	
	fi
	done
	if [[ $urz == 1 ]];then
		install_rz
	fi
	if [[ $urz == 2 ]];then
		[[ ! -e /serverspeeder/bin/serverSpeeder.sh ]] && echo "没有安装 锐速(Server Speeder)，请检查 !" && exit 1
		echo "确定要卸载 锐速(Server Speeder)？[y/N]" && echo
		stty erase '^H' && read -p "(默认: n):" unyn
		[[ -z ${unyn} ]] && echo && echo "已取消..." && exit 1
		if [[ ${unyn} == [Yy] ]]; then
			chattr -i /serverspeeder/etc/apx*
			/serverspeeder/bin/serverSpeeder.sh uninstall -f
			echo && echo "锐速(Server Speeder) 卸载完成 !" && echo
		fi
	fi
	if [[ $urz == 3 ]];then
		[[ ! -e /serverspeeder/bin/serverSpeeder.sh ]] && echo "没有安装 锐速(Server Speeder)，请检查 !" && exit 1
		/serverspeeder/bin/serverSpeeder.sh start
		/serverspeeder/bin/serverSpeeder.sh status
	fi
	if [[ $urz == 4 ]];then
		[[ ! -e /serverspeeder/bin/serverSpeeder.sh ]] && echo "没有安装 锐速(Server Speeder)，请检查 !" && exit 1
		/serverspeeder/bin/serverSpeeder.sh stop
	fi
	if [[ $urz == 5 ]];then
		[[ ! -e /serverspeeder/bin/serverSpeeder.sh ]] && echo "没有安装 锐速(Server Speeder)，请检查 !" && exit 1
		/serverspeeder/bin/serverSpeeder.sh restart
		/serverspeeder/bin/serverSpeeder.sh status
	fi
	if [[ $urz == 6 ]];then
		[[ ! -e /serverspeeder/bin/serverSpeeder.sh ]] && echo "没有安装 锐速(Server Speeder)，请检查 !" && exit 1
		/serverspeeder/bin/serverSpeeder.sh status
	fi
fi
install_ls(){
	[[ -e /appex/bin/serverSpeeder.sh ]] && echo "LotServer 已安装 !" && exit 1
	#Github: https://github.com/0oVicero0/serverSpeeder_Install
	wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh"
	[[ ! -e "/tmp/appex.sh" ]] && echo "LotServer 安装脚本下载失败 !" && exit 1
	bash /tmp/appex.sh 'install'
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "appex" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		echo "LotServer 安装完成 !" && exit 1
	else
		echo "LotServer 安装失败 !" && exit 1
	fi
}
if [[ $devc == 7 ]];then
	echo "你要做什么？"
	echo "1.安装 LotServer"
	echo "2.卸载 LotServer"
	echo "————————"
	echo "3.启动 LotServer"
	echo "4.停止 LotServer"
	echo "5.重启 LotServer"
	echo "6.查看 LotServer 状态"
	echo "注意： 锐速和LotServer不能同时安装/启动！"
	while :; do echo
	read -p "请选择： " uls
	[ -z "$uls" ] && ssr && break
	if [[ ! $uls =~ ^[1-6]$ ]]; then
		echo "输入错误! 请输入正确的数字!"
	else
		break	
	fi
	done
	if [[ $uls == 1 ]];then
		install_ls
	fi
	if [[ $uls == 2 ]];then 
		echo "确定要卸载 LotServer？[y/N]" && echo
		stty erase '^H' && read -p "(默认: n):" unyn
		[[ -z ${unyn} ]] && echo && echo "已取消..." && exit 1
		if [[ ${unyn} == [Yy] ]]; then
			wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh" && bash /tmp/appex.sh 'uninstall'
			echo && echo "LotServer 卸载完成 !" && echo
		fi
	fi
	if [[ $uls == 3 ]];then
		[[ ! -e /appex/bin/serverSpeeder.sh ]] && echo "没有安装 LotServer，请检查 !" && exit 1
		/appex/bin/serverSpeeder.sh start
		/appex/bin/serverSpeeder.sh status
	fi
	if [[ $uls == 4 ]];then
		[[ ! -e /appex/bin/serverSpeeder.sh ]] && echo "没有安装 LotServer，请检查 !" && exit 1
		/appex/bin/serverSpeeder.sh stop
	fi
	if [[ $uls == 5 ]];then
		[[ ! -e /appex/bin/serverSpeeder.sh ]] && echo "没有安装 LotServer，请检查 !" && exit 1
		/appex/bin/serverSpeeder.sh restart
		/appex/bin/serverSpeeder.sh status
	fi
	if [[ $uls == 6 ]];then
		[[ ! -e /appex/bin/serverSpeeder.sh ]] && echo "没有安装 LotServer，请检查 !" && exit 1
		/appex/bin/serverSpeeder.sh status
	fi
fi
if [[ $devc == 8 ]];then
	cd /usr/local/SSR-Bash-Python
	if [[ -e /root/lkl/run.sh ]];then
		echo "你已安装过LKL"
	else
		echo "开始安装LKL"
		wget -q -N --no-check-certificate https://raw.githubusercontent.com/Huiaini/UML-LKL/master/lkl-install.sh && bash lkl-install.sh
		rm -f lkl-install.sh
	fi
	if [[ -d $PWD/uml-ssr-64 ]];then
		echo "你已安装过UML"
	else
		echo "开始安装UML"
		wget -q -N --no-check-certificate https://raw.githubusercontent.com/Huiaini/UML-LKL/master/uml.sh && bash uml.sh
	fi
fi