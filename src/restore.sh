#!/bin/bash

restore(){
    # 列出所有可用的备份组
    ls -tr $BackupFolder # 按时间排序，逆向（最新的在最后）
    read -p "选择要从哪个文件恢复:" -a RestoreFolder
    if [ ! -d $BackupFolder/$RestoreFolder ]
    then
        echo "没有路径"
        exit 11
    fi

    # 列出所有可用的备份
    ls -tr $BackupFolder/$RestoreFolder | grep backup.tar
    # 输入要使用的备份
    read -p "选择要从哪些文件恢复，用空格分开[靠前的文件会先被解压，请按照时间顺序填写]:" -a RestoreFile

    # 循环释放每个输入的文件
    for i in "${RestoreFile[@]}"
    do
        # 如果没有文件则报错
        if [ ! -f $BackupFolder/$RestoreFolder/$i ]
        then
            echo "没有路径"
            exit 11
        fi
        # 解压文件
        tar -zxvf $BackupFolder/$RestoreFolder/$i -C $RootPath
    done
}
