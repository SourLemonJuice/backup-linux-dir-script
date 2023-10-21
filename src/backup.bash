#!/bin/bash

# exclude参数是要排除的路径，把系统的临时信息放进去没什么用
# 此处路径是相对于根路径的
# TODO 过滤失效
exclude="--exclude=./lost+found --exclude=./sys --exclude=./proc --exclude=./boot --exclude=./dev --exclude=./mnt"

full_backup () {
    # 完整备份都是每组的第一次备份所以要创建组的文件夹
    mkdir -v $BackupFolder/$(cat $BackupFolder/.now_back)

    # 这里cd到要工作的目录是因为不这么做生成的tar会先有一个工作目录名称的文件夹再是工作目录里的内容
    # 我不知道怎么让他不这样也不想再解压上下工夫，直接扔到子shell里方便一些
    cd $RootPath
    tar -g $BackupFolder/$(cat $BackupFolder/.now_back)/snapshot -zcvf $BackupFolder/$(cat $BackupFolder/.now_back)/$(date +%Y-%m-%d_%H-%M)_all_backup.tar.gz "${exclude}" .
}

add_backup(){
    cd $RootPath
    tar -g $BackupFolder/$(cat $BackupFolder/.now_back)/snapshot -zcvf $BackupFolder/$(cat $BackupFolder/.now_back)/$(date +%Y-%m-%d_%H-%M-%S)_backup.tar.gz "${exclude}" .
}
