
backup(){

    case $1 in 
    full)
        # 等待用户最终确认
        read -p "tar完整备份模式 [按回车确认]"

        # FileAppendName="first_"

        # 刷新文件所在的组的编号文件
        echo -n $(date +%s_%Y-%m-%d_%H-%M-%S) > $Now_Backup_FilePath
        Now_Backup=$(sed -n "1,1p" $BackupFolder/.now_backup)
        logger "新编号为 $Now_Backup"

        # 完整备份都是每组的第一次备份所以要创建组的文件夹
        logger 'file' "$(mkdir -v $BackupFolder/$Now_Backup || exit 1)"

        # 写入当前版本脚本的重要信息用来向后兼容
        echo script version:$(cat "$ShellFilePath/version") > $BackupFolder/$Now_Backup/.template
        echo file name template:'$(date +%s_%Y-%m-%d_%H-%M-%S)_${FileAppendName}backup.tar${ZipExtensionName}' >> $BackupFolder/$Now_Backup/.template
    ;;
    add)
        # 等待用户最终确认
        read -p "tar增量备份模式 [按回车确认]"

        # FileAppendName=""
    ;;
    *)
        echo "backup函数 无效参数" && exit 1
    ;;
    esac

    case $2 in 
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
    echo tar压缩参数: $ZipMode
    separator
    {
        read -p "[按回车确认]" -a Final_Tip
        if [[ ! -z $Final_Tip ]];then
            logger 'both' "用户已取消操作"
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
    -"${ZipMode}"cvf $BackupFolder/$Now_Backup/$(date +%s_%Y-%m-%d_%H-%M-%S)_${FileAppendName}backup.tar${ZipExtensionName}\
    --overwrite\
    --one-file-system\
    ${excludes}\
    .

    # 写入进打包历史
    echo $(date +%s_%Y-%m-%d_%H-%M-%S)_${FileAppendName}backup.tar${ZipExtensionName} >> $BackupFolder/$Now_Backup/.log
    # logggggg
    logger 'both' "$(date +%s_%Y-%m-%d_%H-%M-%S)_${FileAppendName}backup.tar${ZipExtensionName} 打包结束"
}
