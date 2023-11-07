
init(){
    # 加载一些小东西
    # 日志函数
    source $ShellFilePath/logger.sh
    # 输出数组内容
    source $ShellFilePath/println_array_items.sh
    # 打印分割线
    source $ShellFilePath/separator.sh

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
    Now_Backup_FilePath="$BackupFolder/.now_backup"
    if [[ -f $BackupFolder/.now_backup ]]; then
        Now_Backup=$(sed -n "1,1p" $BackupFolder/.now_backup)
    else
        Now_Backup=''
    fi

    LogName=running.log
    # 写入日志的第一行日期
    > $RunningLogPath/$LogName || exit 1
    logger 'file' "$(date +%s_%Y-%m-%d_%T) $0 $@"
}
