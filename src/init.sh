
init(){
    # 检测权限
    if [[ $NeedRoot -eq 1 ]] && [[ ! $(id -u) -eq 0 ]]
    then
        echo "需要root权限执行"
        exit 1
    fi

    if [[ $Disable_init_Path_Detection -eq 0 ]]; then
        # 创建备份文件的文件夹
        if [[ ! -d $BackupFolder ]]; then
            logger 'file' "$(mkdir -vp $BackupFolder || exit 1)"
        fi
        # 创建log文件夹
        if [[ ! -d $RunningLogPath ]]; then
            logger 'file' "$(mkdir -vp $RunningLogPath || exit 1)"
        fi
    fi

    # 设置备份组的编号
    Now_Backup_FilePath="$BackupFolder/.Now_Backup"
    if [[ -f $BackupFolder/.Now_Backup ]]; then
        Now_Backup=$(sed -n "1,1p" $BackupFolder/.Now_Backup)
    else
        Now_Backup=''
    fi

    LogName=running.log
    # 写入日志的第一行日期
    > $RunningLogPath/$LogName || exit 1
    logger 'file' "$(date +%s_%Y-%m-%d_%T) $0 $@"
}

# 分隔线函数
separator(){
    if [[ -z $1 ]] || [[ ! ${#1} -eq 1 ]]; then
        Character='='
    else
        Character=$1
    fi

    ShellWidth=$(stty size|awk '{print $2}')
    yes "$Character" |sed $ShellWidth'q' |tr -d "\n" && echo 
}

# 循环输出数组内的值
println_array_items(){
    for i in $@; do
        echo $i
    done
}

# 写日志咯
logger(){
    case $1 in
    both)
        echo $2
        echo "[$(date +%T)] $2" >> $RunningLogPath/$LogName
    ;;
    term)
        echo $2
    ;;
    file)
        echo "[$(date +%T)] $2" >> $RunningLogPath/$LogName
    ;;
    *)
        # 保留缺省情况
        echo $@
        echo "[$(date +%T)] $@" >> $RunningLogPath/$LogName
    ;;
    esac
}
