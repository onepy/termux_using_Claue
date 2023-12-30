#!/bin/bash

# 检查是否存在git指令
if command -v git &> /dev/null; then
    echo "git指令存在"
    # 输出git版本号
    git --version
else
    echo "git指令不存在，建议回termux下载git喵~"
fi

# 检查是否存在node指令
if command -v node &> /dev/null; then
    echo "node指令存在"
    # 输出node版本号
    node --version
else
    echo "node指令不存在，正在尝试重新下载喵~"
    curl -O https://nodejs.org/dist/v20.10.0/node-v20.10.0-linux-arm64.tar.xz
    tar xf node-v20.10.0-linux-arm64.tar.xz
    echo "export PATH=\$PATH:/root/node-v20.10.0-linux-arm64/bin" >>/etc/profile
    source /etc/profile
  if command -v node &> /dev/null; then
    echo "node成功下载"
    # 输出node版本号
    node --version                                                else
    echo "node下载失败，╮(︶﹏︶)╭，自己尝试手动下载吧"
    exit 1

  fi
fi

if [ ! -d "SillyTavern" ] || [ ! -f "SillyTavern/start.sh" ]; then
    echo "SillyTavern不存在，正在通过git下载..."
	cp -r SillyTavern/public SillyTavern_public_bak
	rm -rf SillyTavern
    git clone https://github.com/SillyTavern/SillyTavern SillyTavern
fi

if [ ! -d "clewd" ]; then
	echo "clewd不存在，正在通过git下载..."
	git clone https://github.com/teralomaniac/clewd
	cd clewd
	bash start.sh
        cd /root
elif [ ! -f "clewd/config.js" ]; then
    cd clewd
    bash start.sh
    cd /root
fi

if [ ! -d "SillyTavern" ] || [ ! -f "SillyTavern/start.sh" ]; then
	echo -e "(*꒦ິ⌓꒦ີ)\n\033[0;33m hoping：因网络波动文件下载失败了，更换网络后再试喵~\n\033[0m"
 	rm -rf SillyTavern
	exit 2
fi

if  [ ! -d "clewd" ] || [ ! -f "clewd/config.js" ]; then
	echo -e "(*꒦ິ⌓꒦ີ)\n\033[0;33m hoping：因网络波动文件下载失败了，更换网络后再试喵~\n\033[0m"
  	rm -rf clewd
	exit 3
fi

clewd_dir=clewd
echo -e "\033[0;36mhoping喵~让你选一个执行（输入数字即可），懂了吗？\033[0;38m(｡ì _ í｡)\033[0m\n\033[0m\033[0;33m--------------------------------------\n\033[0m\033[0;31m选项0 退出脚本\n\033[0m\033[0;33m选项1 启动clewd\n\033[0m\033[0;37m选项2 启动酒馆\n\033[0m\033[0;33m选项3 修改clewd配置\n\033[0m\033[0;37m选项4 修改酒馆配置\n\033[0m\033[0;33m选项5 删除现有clewd，下载最新测试修改版clewd\n\033[0m\033[0;37m选项6 保留数据更新酒馆最新版本\n\033[0m\033[0;33m--------------------------------------\n\033[0m\033[0;31m选项00 更新脚本\n\033[0m\033[0;33m--------------------------------------\n\033[0m\033[0;35m不准选其他选项，听到了吗？\n\033[0m\n(⇀‸↼‶)"
read option

# 执行相应的操作
case $option in
   00)
       rm -rf sac.sh
       curl -O https://raw.githubusercontent.com/hopingmiao/termux_using_Claue/main/sac.sh
        ;;
    0)
        exit 4
	;;
    1)
        cd clewd
	bash start.sh
        ;;
    2)
        cd SillyTavern
	bash start.sh
        ;;
    3)
		echo -e "\033[0;36mhoping：选一个执行喵~\n\033[0m\033[0;33m--------------------------------------\n\033[0m\033[0;33m选项1 修改clewd密码\n\033[0m\033[0;37m选项2 修改clewd端口\n\033[0m\033[0;33m选项3 为clewd添加cookies\n\033[0m\033[0;33m--------------------------------------\n\033[0m"
  		read option_3
		case $option_3 in
		1)
  		# 询问用户是否修改密码
		read -p "是否修改密码?(y/n)" choice

		if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
  		# 读取用户输入的新密码
 		 read -p "请输入新密码\n（不是你本地部署设密码干哈啊？）:" new_pass

		  # 修改密码
		  sed -i 's/"ProxyPassword": ".*",/"ProxyPassword": "'$new_pass'",/g' $clewd_dir/config.js

 		 echo "密码已修改为$new_pass"
		else
		  echo "未修改密码"
		fi
		;;
		2)
		# 提示是否修改端口
		read -p "是否要修改开放端口?(y/n)" choice

		if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
  		 # 读取用户输入的端口号
  		 read -p "请输入开放的端口号:" custom_port

  		  # 更新配置文件的端口号
 		  sed -i 's/"Port": [0-9]*/"Port": '$custom_port'/g' $clewd_dir/config.js

 		  echo "端口已修改为$custom_port"
		else
 		 echo "未修改端口号"
		fi
		;;
		3)
		echo "hoping：请输入你的cookie文本喵~(回车进行保存，如果全部输入完后按一次ctrl+D即可退出输入):"
		while IFS= read -r line; do
		  cookies=$(echo "$line" | grep -E -o '"?sessionKey=[^"]{100,120}AA"?' | tr -d "\"'")
		  if [ -n "$cookies" ]; then
		    echo "我猜你的cookies是:\n"
		    echo "$cookies"

		    # Format cookies, one per line with quotes
		    cookies=$(echo "$cookies" | tr ' ' '\n' | sed -e 's/^/"/; s/$/"/g')

		    # Join into array
		    cookie_array=$(echo "$cookies" | tr '\n' ',' | sed 's/,$//')
                    # Update config.js
		    sed -i "/\"CookieArray\"/s/\[/\[$cookie_array\,/" ./$clewd_dir/config.js

		    echo "Cookies成功被添加到config.js文件了喵~"
 		       else
		                echo "没有找到cookie喵~o(╥﹏╥)o，要不检查一下cookie是不是输错了吧？(如果要退出输入请按Ctrl+D)"
		  fi
		done

		echo "cookies成功输入了，(*^▽^*)"
		;;
		*)
		echo "什么都没有执行喵~"
		;;
	esac
        ;;
    4)
        read -p "是否要修改开放端口?(y/n)" choice

if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
   # 读取用户输入的端口号
   read -p "请输入开放的端口号:" custom_port
                                                                      # 更新配置文件的端口号
   sed -i 's/port: [0-9]*/port: '$custom_port'/g' SillyTavern/config.yaml

   echo "端口已修改为$custom_port"
else
  echo "未修改端口号"
fi
source /root/.bashrc
        ;;
    5)
        cd /root
	rm -rf clewd
        git clone -b test https://github.com/teralomaniac/clewd.git
	cd clewd
        bash start.sh
	cd /root
        ;;
    6)
    if [ -d "SillyTavern_old" ]; then                                   
    NEW_FOLDER_NAME="SillyTavern_$(date +%Y%m%d)"
    mv SillyTavern_old $NEW_FOLDER_NAME
    fi                                                                
git clone https://github.com/SillyTavern/SillyTavern.git SillyTavern_new

    if [ ! -d "SillyTavern_new" ]; then
    echo -e "(*꒦ິ⌓꒦ີ)\n\033[0;33m hoping：因为网络波动下载失败了，更换网络再试喵~\n\033[0m"
    exit 5
    fi
    
cp -r SillyTavern/public/characters/. SillyTavern_new/public/characters/
cp -r SillyTavern/public/chats/. SillyTavern_new/public/chats/       
cp -r SillyTavern/public/worlds/. SillyTavern_new/public/worlds/
cp -r SillyTavern/public/groups/. SillyTavern_new/public/groups/
cp -r SillyTavern/public/group\ chats/. SillyTavern_new/public/group\ chats/
cp -r SillyTavern/public/OpenAI\ Settings/. SillyTavern_new/public/OpenAI\ Settings/
cp -r SillyTavern/public/User\ Avatars/. SillyTavern_new/public/User\ Avatars/
cp -r SillyTavern/public/backgrounds/. SillyTavern_new/public/backgrounds/
mv SillyTavern SillyTavern_old                                    
mv SillyTavern_new SillyTavern

read -p "是否删除旧版本,请输入Y/N:" para
case $para in
        [yY])
                read -p "若要删除请再次确认" queren

                case $queren in
                        [yY])
                                rm -rf SillyTavern_old
				echo "hoping:酒馆更新成功了喵~"
                                ;;
                        [nN])
                                echo "保留旧版本"
				echo "hoping:酒馆更新结束了喵~"
                                ;;
                        *)
                                echo "错误的输入"
                                read -p "已经默认保留旧版本"
                                echo "hoping:酒馆更新结束了喵~"
                                ;;
                esac
                ;;
        [nN])
                echo "保留旧版本"
		echo "hoping:酒馆更新结束了喵~"
                ;;
        *)
                echo "错误的输入"
                read -p "已经默认保留旧版本"
                echo "hoping:酒馆更新结束了喵~"
				;;
esac
        ;;
    *)
	    echo -e "m9( ｀д´ )!!!! \n\033[0;36m坏猫猫居然不听话，存心和我hoping喵~过不去是吧？\033[0m"
	;;
esac

exit
