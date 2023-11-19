
init(){

    # 检测权限
    if [[ $NeedRoot -eq 1 ]] && [[ ! $(id -u) -eq 0 ]]
    then
        echo "需要root权限执行"
        exit 1
    fi

    # 创建备份文件的文件夹
    if [[ ! -d $BackupFolder ]]; then
        logger 'file' "$(mkdir -vp $BackupFolder || exit 1)"
    fi

    # 设置备份组的编号
    Now_Backup_FilePath="$BackupFolder/.now_backup"
    if [[ -f $BackupFolder/.now_backup ]]; then
        Now_Backup=$(sed -n "1,1p" $BackupFolder/.now_backup)
    else
        Now_Backup=''
    fi
    
}
