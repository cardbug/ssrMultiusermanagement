#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

#Main
checkqr(){
	if [[ ! -e /usr/bin/qr ]];then
		if [[ ! -e /usr/local/bin/qr ]];then
			echo "你还未安装二维码生成模块"
			echo "按回车键继续，Ctrl+C退出！"
			read -s
			echo "正在安装，通常这不需要太多时间"
			pip -q install qrcode
			pip -q install git+git://github.com/ojii/pymaging.git
			pip -q install git+git://github.com/ojii/pymaging-png.git
			if [[ -e /usr/bin/qr ]];then
				echo "安装完成！"
			elif [[ -e /usr/local/bin/qr ]];then
				echo "安装完成！"
			else
				echo "安装失败 请检查你的Python是否正常，并尝试重新安装"
				exit 1
			fi
		fi
	fi
}

readmsg(){
	cd /usr/local/shadowsocksr
	echo "为已有用户生成二维码："
	echo ""
	echo "1.使用用户名"
	echo "2.使用端口"
	echo ""
	while :; do echo
		read -p "请选择： " lsid
		if [[ ! $lsid =~ ^[1-2]$ ]]; then
			if [[ $lsid == "" ]]; then
				bash /usr/local/SSR-Bash-Python/user.sh 
				exit 0
			fi
			echo "输入错误! 请输入正确的数字!"
		else
			break	
		fi
	done
	if [[ $lsid == 1 ]];then
		read -p "输入用户名： " uid
	elif [[ $lsid == 2 ]];then
		read -p "输入端口号： " uid
	else
		echo "输入错误! 请输入正确的数字!"
	fi
}

checkqr
if [[ $1 == "" ]];then
	readmsg
	if [[ $lsid == 1 ]];then
		ssrmsg=`python mujson_mgr.py -l -u $uid | tail -n 1 | sed 's/^[ \t]*//g'`
		username=`python mujson_mgr.py -l -u $uid | head -n 2 | tail -n 1 | awk -F" : " '{ print $2 }'`
	elif [[ $lsid == 2 ]];then
		ssrmsg=`python mujson_mgr.py -l -p $uid | tail -n 1 | sed 's/^[ \t]*//g'`
		username=`python mujson_mgr.py -l -p $uid | head -n 2 | tail -n 1 | awk -F" : " '{ print $2 }'`
	fi
	if [[ "$ssrmsg" == "" ]];then
		echo "该端口号或用户名不存在，请确认后输入!"
		readmsg
	fi
elif [[ $1 == "u" ]];then
	ssrmsg=`python mujson_mgr.py -l -u $2 | tail -n 1 | sed 's/^[ \t]*//g'`
	username=`python mujson_mgr.py -l -u $2 | head -n 2 | tail -n 1 | awk -F" : " '{ print $2 }'`
elif [[ $1 == "p" ]];then
	ssrmsg=`python mujson_mgr.py -l -p $2 | tail -n 1 | sed 's/^[ \t]*//g'`
	username=`python mujson_mgr.py -l -p $2 | head -n 2 | tail -n 1 | awk -F" : " '{ print $2 }'`
fi

cd ~
if [[ ! -d ./SSRQR ]];then
	mkdir SSRQR
fi
cd SSRQR
if [[ -e $username.png ]];then
	rm -f $username.png
fi
qr --factory=pymaging "$ssrmsg" > $username.png
if [[ -e "$username.png" ]];then
	echo "链接信息：$ssrmsg"
	echo "二维码生成成功!位于${HOME}/SSRQR/${username}.png"
else
	echo "由于奇奇怪怪的原因，二维码未能成功生成"
fi
