backup(){

    case $1 in 
    full)
        # 等待用户最终确认
        read -p "准备tar完整备份模式 [按回车确认]"
        logger 'file' "开始tar增量模式备份"

        # 刷新文件所在的组的编号文件
        Now_Backup=$(date +%s_%Y-%m-%d_%H-%M-%S)
        logger 'both' "设置新编号为 $Now_Backup"

        # 完整备份都是每组的第一次备份所以要创建组的文件夹
        logger 'file' "$(mkdir -v $BackupFolder/$Now_Backup || exit 1)"

        # 写入当前版本脚本的重要信息用来向后兼容
        # echo script version:$(cat "$ShellFilePath/version") > $BackupFolder/$Now_Backup/.template
        # echo file name template:'$(date +%s_%Y-%m-%d_%H-%M-%S)_backup.tar${ZipExtensionName}' >> $BackupFolder/$Now_Backup/.template
    ;;
    add)
        # 等待用户最终确认
        read -p "准备tar增量备份模式 [按回车确认]"
        logger 'file' "开始tar增量模式备份"
    ;;
    *)
        logger 'both' "backup函数 无效参数: $1" && exit 1
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
    logger 'file' "----备份详细信息报告----"
    separator
    logger 'both' "源: $RootPath"
    logger 'both' "目标文件夹: $BackupFolder/$Now_Backup"
    logger 'both' "排除参数: $excludes"
    logger 'both' "接收到的备份模式: $1"
    logger 'both' "tar压缩参数: $ZipMode"
    separator
    logger 'file' "----报告结束----"
    # 如果退出就删除刚创建的文件夹
    # TODO 这里的rm仍然有 -i 去寻求用户的意见，防止出现什么问题，可以在前面添加判断要删除的路径是否为空，这样对前面的逻辑也好更不容易出错
    {
        read -n 1 -p "[回车继续 其他输入则终止]" Final_Tip
        if [[ ! -z $Final_Tip ]];then
            logger 'both' "用户已取消操作"
            logger 'both' "当前时间: $(date +%x-%T) 刚才的目标: $Now_Backup 请及时退出rm"
            rm -ri $BackupFolder/$Now_Backup && logger 'both' "成功删除未使用的文件夹 $BackupFolder/$Now_Backup"
            # 如果rm失败就会把错误码传递出去
            exit $?
        fi
    }

    # 这里cd到要工作的目录是因为不这么做生成的tar会先有一个工作目录名称的文件夹再是工作目录里的内容
    # 懒得找别的办法了（-:
    (
    cd $RootPath || exit 1
    logger 'file' "----开始打包"
    tar -g $BackupFolder/$Now_Backup/.tar_snapshot\
    -"${ZipMode}"cvf $BackupFolder/$Now_Backup/$(date +%s_%Y-%m-%d_%H-%M-%S)_backup.tar${ZipExtensionName}\
    --overwrite\
    --one-file-system\
    ${excludes}\
    .\
    2>&1
    ) | logger 'stdin'

    # 写入当前备份的组，如果是增量内容将不变，如果是完全备份将写入新的编号，都是为了最终确认呀啊啊啊
    echo -n $Now_Backup > $Now_Backup_FilePath
    logger 'file' "写入储存库中的.now_backup文件为 > $Now_Backup"

    # 写入进打包历史
    echo $(date +%s_%Y-%m-%d_%H-%M-%S)_backup.tar${ZipExtensionName} >> $BackupFolder/$Now_Backup/.log
    # 这里读取最后一行.log作为输出，可能并不准确，但不会出现对不上的情况
    logger 'both' "$(tail -n 1 $BackupFolder/$Now_Backup/.log) 打包结束" "打包结束 .log的最后一项为 $(tail -n 1 $BackupFolder/$Now_Backup/.log)"
}
