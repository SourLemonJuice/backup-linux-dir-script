backup(){

    case $1 in 
    full)
        # 等待用户最终确认
        read -p "准备tar完整备份模式 [按回车确认]"
        llib_logger 'file' "开始tar增量模式备份"

        # 刷新文件所在的组的编号文件
        Now_Backup=$(date +%s_%Y-%m-%d_%H-%M-%S)
        llib_logger 'both' "设置新编号为 $Now_Backup"

        # 完整备份都是每组的第一次备份所以要创建组的文件夹
        llib_logger 'file' "$(mkdir -v $BackupFolder/$Now_Backup || exit 1)"

        # 写入当前版本脚本的重要信息用来向后兼容
        # echo script version:$(cat "$ShellFilePath/version") > $BackupFolder/$Now_Backup/.template
        # echo file name template:'$(date +%s_%Y-%m-%d_%H-%M-%S)_backup.tar${ZipExtensionName}' >> $BackupFolder/$Now_Backup/.template
    ;;
    add)
        # 等待用户最终确认
        read -p "准备tar增量备份模式 [按回车确认]"
        llib_logger 'file' "开始tar增量模式备份"
    ;;
    *)
        llib_logger 'both' "backup函数 无效参数: $1" && exit 1
    ;;
    esac

    # 检测是否有设置默认压缩模式
    if [[ ! -z $Default_Zip_Mode ]]; then
        Tar_Zip_Mode=$Default_Zip_Mode
        llib_logger 'file' "强制使用 $Default_Zip_Mode 作为tar压缩参数"
    else
        Tar_Zip_Mode=$2
    fi
    case $Tar_Zip_Mode in 
    -z)
        llib_logger 'file' "gzip压缩模式"
        ZipMode="z"
        ZipExtensionName=".gz"
    ;;
    *)
        llib_logger 'file' "无压缩模式"
        ZipMode=""
        ZipExtensionName=""
    ;;
    esac

    # exclude参数是要排除的路径，把系统的临时信息放进去没什么用，这里用变量存储会有问题所以两边都写了一遍
    # excludes="--exclude=./lost+found --exclude=./sys --exclude=./proc --exclude=./dev --exclude=./mnt --exclude=./media"
    excludes="--exclude=./lost+found --exclude=.$BackupFolder"

    # 等待用户最终确认
    llib_logger 'file' "----备份详细信息报告----"
    llib_separator
    llib_logger 'both' "源: $RootPath"
    llib_logger 'both' "目标文件夹: $BackupFolder/$Now_Backup"
    llib_logger 'both' "排除参数: $excludes"
    llib_logger 'both' "接收到的备份模式: $1"
    llib_logger 'both' "tar压缩参数: $ZipMode"
    llib_separator
    llib_logger 'file' "----报告结束----"

    # 让用户决定是否继续
    read -s -n 1 -p "[按回车立即开始 其他输入则终止]" Final_Tip
    # 如果确定退出就删除刚创建的文件夹
    if [[ ! -z $Final_Tip ]];then
        # 只有完整备份才需要删除，增量模式在这之前不会改动文件
        if [ $1 == "full" ];then
            llib_logger 'both' "用户已取消操作 (完整备份模式)"
            llib_logger 'file' "当前时间: $(date +%x-%T) 准备删除的目标: $Now_Backup"
            # !!! rm 的路径在init函数中均有检测，如果要动请一定要确定不会出现空的函数
            # 或者像现在一样尽量使用仅删除文件夹模式
            rm -d $BackupFolder/$Now_Backup && llib_logger 'both' "成功删除未使用的空文件夹 $BackupFolder/$Now_Backup"
            # 把rm的错误码传递出去
            # 正常如果rm没问题会执行日志记录，但如果有问题会停在rm，后面的llib_logger不会覆盖掉rm的"错误码"
            exit $?
        fi
        # 其他模式退出可以直接exit
        llib_logger 'both' "用户已取消操作"
        exit 0
    fi

    # 这里cd到要工作的目录是因为不这么做生成的tar会先有一个工作目录名称的文件夹再是工作目录里的内容
    # 懒得找别的办法了（-:
    (
    cd $RootPath || exit 1
    llib_logger 'file' "----开始打包"
    tar -g $BackupFolder/$Now_Backup/.tar_snapshot\
    -"${ZipMode}"cvf $BackupFolder/$Now_Backup/$(date +%s_%Y-%m-%d_%H-%M-%S)_backup.tar${ZipExtensionName}\
    --overwrite\
    --one-file-system\
    ${excludes}\
    .\
    2>&1
    ) | llib_logger 'stdin'

    # 写入当前备份的组，如果是增量内容将不变，如果是完全备份将写入新的编号，都是为了最终确认呀啊啊啊
    echo -n $Now_Backup > $Now_Backup_FilePath
    llib_logger 'file' "写入储存库中的.now_backup文件为 > $Now_Backup"

    # 写入进打包历史
    echo $(date +%s_%Y-%m-%d_%H-%M-%S)_backup.tar${ZipExtensionName} >> $BackupFolder/$Now_Backup/.log
    # 这里读取最后一行.log作为输出，可能并不准确，但不会出现对不上的情况
    llib_logger 'both' "$(tail -n 1 $BackupFolder/$Now_Backup/.log) 打包结束" "打包结束 .log的最后一项为 $(tail -n 1 $BackupFolder/$Now_Backup/.log)"
}
