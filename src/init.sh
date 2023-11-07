
init(){
    # 检测权限
    if [[ $NeedRoot -eq 1 ]] && [[ ! $(id -u) -eq 0 ]]
    then
        echo "需要root权限执行"
        exit 1
    fi

    # 在改动文件前确认
    read -p "开始运行脚本(后面还有确认项) [回车]"

    # 创建备份文件的文件夹
    if [[ ! -d $BackupFolder ]]; then
        mkdir -vp $BackupFolder
    fi
    # 创建log文件夹
    if [[ ! -d $RunningLogPath ]]; then
        mkdir -vp $RunningLogPath
    fi

    # 设置备份组的编号
    Now_Backup_FilePath="$BackupFolder/.now_backup"
    if [[ -f $BackupFolder/.now_backup ]]; then
        Now_Backup=$(sed -n "1,1p" $BackupFolder/.now_backup)
    else
        Now_Backup=''
    fi

    LogName=running.log
    # 写入日志的第一行日期
    > $RunningLogPath/$LogName
    logger "$(date +%s_%Y-%m-%d_%T) $0 $@"
}

# 分隔线函数
separator(){
    ShellWidth=$(stty size|awk '{print $2}')
    yes "=" |sed $ShellWidth'q' |tr -d "\n" && echo 
}

# 循环输出数组内的值
println_array_items(){
    for i in $@; do
        echo $i
    done
}

# 写日志咯
logger(){
    echo $@
    echo "$(date +%T) $@" >> $RunningLogPath/$LogName
}
