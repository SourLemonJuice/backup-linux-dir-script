#!/bin/bash

# 读取配置文件
source path.conf

# 相对路径改绝对路径
BackupFolder=$(cd $BackupFolder && pwd)
RootPath=$(cd $RootPath && pwd)

# 检测权限
if [ ! $(id -u) -eq 0 ]
then
    echo "需要root权限执行"
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
    echo "参数格式错误"
    exit 1
fi
# 格式化getopt的输出
eval set -- "$Options"

while true
do
    case $1 in
        -b)
            read -p "即将备份 $RootPath [按回车确认]"
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
            echo "未知参数 $1"
            exit 2
        ;;
    esac

    shift
done
