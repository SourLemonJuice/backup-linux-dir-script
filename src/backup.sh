#!/bin/bash
backup(){

    case $1 in 
    all)
        FileAppendName="all_"
        # 刷新文件所在的组的编号文件
        echo $(date +%s) > $BackupFolder/.now_back
        # 完整备份都是每组的第一次备份所以要创建组的文件夹
        mkdir -v $BackupFolder/$(cat $BackupFolder/.now_back)
    ;;
    add)
        FileAppendName=""
    ;;
    *)
        echo "backup函数 无效参数"
        exit 22
    ;;
    esac

    # exclude参数是要排除的路径，把系统的临时信息放进去没什么用，这里用变量存储会有问题所以两边都写了一遍
    # excludes="--exclude=./lost+found --exclude=./sys --exclude=./proc --exclude=./dev --exclude=./mnt --exclude=./media"
    excludes="--exclude=lost+found --exclude=$BackupFolder"
    # 这里cd到要工作的目录是因为不这么做生成的tar会先有一个工作目录名称的文件夹再是工作目录里的内容
    # 懒得找别的办法了（-:
    cd $RootPath
    tar -g $BackupFolder/$(cat $BackupFolder/.now_back)/snapshot -zcvf $BackupFolder/$(cat $BackupFolder/.now_back)/${FileAppendName}$(date +%Y-%m-%d_%H-%M)_backup.tar.gz --overwrite --one-file-system ${excludes} .
}
