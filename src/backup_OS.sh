#!/bin/bash

# 只能使用相对路径
BackupFolder=/home/lemon/Documents/file/文件/软件工程/备份linux系统脚本/temp/back
RootPath=/home/lemon/Documents/file/文件/软件工程/备份linux系统脚本/temp/test
# TODO 相对路径改绝对路径

# 检测权限
if [ ! $(id -u) -eq 0 ]
then
    echo "需要root权限"
    exit 4
fi

# 创建备份文件的文件夹
if [ ! -d $BackupFolder ]
then
    mkdir -v $BackupFolder
fi

# 获取参数
Options=$(getopt -o hbr -l help -- "$@")
if [ ! $? -eq 0 ]
then
    echo "参数错误"
    exit 1
fi
# 格式化getopt的输出
eval set -- "$Options"

while true
do
    case $1 in
        -b)
            # TODO 等待用户确认
            {
            cd $RootPath
            tar -zcvf $BackupFolder/$(date +%Y-%m-%d_%H-%M)_backup.tar.gz --exclude=/sys --exclude=/proc --exclude=/boot --exclude=/dev --exclude=/mnt .
            }
        ;;
        -r)
            # 列出所有可用的备份
            ls -tr $BackupFolder
            # 输入要使用的备份
            read -p "选择要从哪个文件恢复:" -a RestoreFile
            # 如果没有文件则报错
            if [ ! -f $BackupFolder/$RestoreFile ]
            then
                echo "路径错误" && exit 3
            fi

            # 解压文件
            tar -zxvf $BackupFolder/$RestoreFile -C $RootPath
        ;;
        -h | --help)
            cat ./help_info
        ;;
        --)
            break
        ;;
        ?)
            echo "未知参数"
            exit 2
        ;;
    esac

    shift
done
