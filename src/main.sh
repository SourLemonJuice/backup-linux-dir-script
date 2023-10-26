#!/bin/bash

# 获取脚本真实路径
ShellFilePath=$( cd $(dirname $0) && pwd)

# 读取配置文件
source $ShellFilePath/config
# 读取备份逻辑函数
source $ShellFilePath/backup.sh
# 读取恢复函数
source $ShellFilePath/restore.sh

# 检测权限
if [[ $NeedRoot -eq 1 && ! $(id -u) -eq 0 ]]
then
    echo "需要root权限执行"
    exit 1
fi

# 相对路径改绝对路径
BackupFolder=$(cd $ShellFilePath && cd $BackupFolder && pwd)
RootPath=$(cd $ShellFilePath && cd $RootPath && pwd)

# 创建备份文件的文件夹
if [ ! -d $BackupFolder ]
then
    mkdir -v $BackupFolder
fi

# 获取参数
Options=$(getopt -o hbrB -l help -- "$@")
if [ ! $? -eq 0 ]
then
    echo "参数格式错误"
    exit 11
fi
# 格式化getopt的输出
eval set -- "$Options"

# 主程序
while true
do
    case $1 in
        -b)
            # 普通备份模式
            # 等待用户最终确认
            read -p "备份 $RootPath 到 $BackupFolder [按回车确认]"
            # 第一次用add模式创建的tar文件名字里有"all"所以才这么写的，不要改（当然最终都能实现啦）
            if [ -f $BackupFolder/$(cat $BackupFolder/.now_back)/snapshot ]
            then
                backup add
            else
                backup all
            fi
        ;;
        -B)
            # 完整备份模式
            # 等待用户最终确认
            read -p "重新完整备份 $RootPath 到 $BackupFolder [按回车确认]"
            backup all
        ;;
        -r)
            # 调用备份函数
            restore
        ;;
        -h | --help)
            cat $ShellFilePath/help_info
        ;;
        --)
            break
        ;;
        ?)
            echo "未知参数 $1"
            exit 11
        ;;
    esac

    shift
done
