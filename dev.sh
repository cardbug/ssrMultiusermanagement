#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

echo "测试区域，请勿随意使用"
echo "1.更新SSR-Bsah"
echo "2.一键封禁BT下载，SPAM邮件流量（无法撤销）"
echo "3.防止暴力破解SS连接信息 (重启后失效)"
echo "4.布署ss-panel(有风险!)"

while :; do echo
	read -p "请选择： " devc
	[ -z "$devc" ] && ssr && break
	if [[ ! $devc =~ ^[1-4]$ ]]; then
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