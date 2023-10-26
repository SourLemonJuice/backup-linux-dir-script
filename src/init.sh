
init(){
    read -p "开始运行脚本(后面还有确认项) [回车]"
    # 检测权限
    if [[ $NeedRoot -eq 1 && ! $(id -u) -eq 0 ]]
    then
        echo "需要root权限执行"
        exit 1
    fi

    # 创建备份文件的文件夹
    if [[ ! -d $BackupFolder ]]; then
        mkdir -vp $BackupFolder
    fi
    # 创建log文件夹
    if [[ ! -d $LogPath ]]; then
        mkdir -vp $LogPath
    fi

    echo "日志路径 $LogPath"
    # 写入日志的第一行日期
    > $LogPath/$LogName
    logger "$(date +%s_%Y-%m-%d_%T) $0 $@"
}

# 分隔线函数
separator(){
    ShellWidth=$(stty size|awk '{print $2}')
    yes "=" |sed $ShellWidth'q' |tr -d "\n" && echo 
}

println_array_items(){
    for i in $@; do
        echo $i
    done
}

logger(){
    echo $@
    echo "$(date +%T) $@" >> $LogPath/$LogName
}
