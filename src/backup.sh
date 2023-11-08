
backup(){

    case $1 in 
    full)
        # 等待用户最终确认
        read -p "tar完整备份模式 [按回车确认]"
        logger 'file' "开始tar增量模式备份"

        # 刷新文件所在的组的编号文件
        Now_Backup=$(date +%s_%Y-%m-%d_%H-%M-%S)
        logger 'both' "设置新编号为 $Now_Backup"

        # 完整备份都是每组的第一次备份所以要创建组的文件夹
        logger 'file' "$(mkdir -v $BackupFolder/$Now_Backup || exit 1)"

        # 写入当前版本脚本的重要信息用来向后兼容
        echo script version:$(cat "$ShellFilePath/version") > $BackupFolder/$Now_Backup/.template
        echo file name template:'$(date +%s_%Y-%m-%d_%H-%M-%S)_backup.tar${ZipExtensionName}' >> $BackupFolder/$Now_Backup/.template
    ;;
    add)
        # 等待用户最终确认
        read -p "tar增量备份模式 [按回车确认]"
        logger 'file' "开始tar增量模式备份"
    ;;
    *)
        echo "backup函数 无效参数" && exit 1
    ;;
    esac

    # 检测是否有设置默认压缩模式
    if [[ ! -z $Default_Zip_Mode ]]; then
        Tar_Zip_Mode=$Default_Zip_Mode
        logger 'file' "强制使用 $Default_Zip_Mode 作为tar压缩参数"
    else
        Tar_Zip_Mode=$2
    fi
    case $Tar_Zip_Mode in 
    -z)
        logger 'file' "gzip压缩模式"
        ZipMode="z"
        ZipExtensionName=".gz"
    ;;
    *)
        logger 'file' "无压缩模式"
        ZipMode=""
        ZipExtensionName=""
    ;;
    esac

    # exclude参数是要排除的路径，把系统的临时信息放进去没什么用，这里用变量存储会有问题所以两边都写了一遍
    # excludes="--exclude=./lost+found --exclude=./sys --exclude=./proc --exclude=./dev --exclude=./mnt --exclude=./media"
    excludes="--exclude=./lost+found --exclude=.$BackupFolder"

    # 等待用户最终确认
    separator
    echo 源: $RootPath
    echo 目标文件夹: $BackupFolder/$Now_Backup
    echo 排除参数: $excludes
    echo 接收到的备份模式: $1
    echo tar压缩参数: $ZipMode
    separator
    {
        read -n 1 -p "[回车继续 其他输入则终止]" Final_Tip
        if [[ ! -z $Final_Tip ]];then
            logger 'both' "用户已取消操作"
            echo "当前时间 $(date +%x-%T)"
            rm -ri $BackupFolder/$Now_Backup
            logger 'both' "删除未使用的文件夹 $BackupFolder/$Now_Backup"
            exit
        fi
    }

    # 这里cd到要工作的目录是因为不这么做生成的tar会先有一个工作目录名称的文件夹再是工作目录里的内容
    # 懒得找别的办法了（-:
    cd $RootPath || exit 1
    logger 'file' "开始打包 $RootPath 到 $BackupFolder/$Now_Backup"
    tar -g $BackupFolder/$Now_Backup/.snapshot\
    -"${ZipMode}"cvf $BackupFolder/$Now_Backup/$(date +%s_%Y-%m-%d_%H-%M-%S)_backup.tar${ZipExtensionName}\
    --overwrite\
    --one-file-system\
    ${excludes}\
    .

    # 写入当前备份的组，如果是增量内容将不变，如果是完全备份将写入新的编号，都是为了最终确认呀啊啊啊
    echo -n $Now_Backup > $Now_Backup_FilePath
    logger 'file' "更新储存库中的.now_backup文件为 $Now_Backup"

    # 写入进打包历史
    echo $(date +%s_%Y-%m-%d_%H-%M-%S)_backup.tar${ZipExtensionName} >> $BackupFolder/$Now_Backup/.log
    # logggggg
    logger 'both' "$(date +%s_%Y-%m-%d_%H-%M-%S)_${FileAppendName}backup.tar${ZipExtensionName} 打包结束"
}
