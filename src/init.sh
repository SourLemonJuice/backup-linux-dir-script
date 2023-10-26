
init(){
    read -p "开始运行脚本(后面还有确认项) [回车]"
    # 检测权限
    if [[ $NeedRoot -eq 1 && ! $(id -u) -eq 0 ]]
    then
        echo "需要root权限执行"
        exit 1
    fi

    # 相对路径改绝对路径
    {
        cd $ShellFilePath || exit 1
        BackupFolder=$(realpath $BackupFolder)
        RootPath=$(realpath $RootPath)
        LogPath=$(realpath $LogPath)
    }

    # 创建备份文件的文件夹
    if [[ ! -d $BackupFolder ]]; then
        mkdir -v $BackupFolder
    fi
    # 创建log文件夹
    if [[ ! -d $LogPath ]]; then
        mkdir -v $LogPath
    fi

    # 写入日志的第一行日期
    echo "$(date +%s_%Y-%m-%d_%H-%M-%S) $0 "$@""> $LogPath/$LogName
}
