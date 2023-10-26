#!/bin/bash

# 获取脚本真实路径
ShellFilePath=$( cd $(dirname $0) && pwd)

# 读取配置文件
source $ShellFilePath/config
# 读取初始化函数
source $ShellFilePath/init.sh
# 读取备份逻辑函数
source $ShellFilePath/backup.sh
# 读取恢复函数
source $ShellFilePath/restore.sh

# 相对路径改绝对路径
{
    cd $ShellFilePath || exit 1
    BackupFolder=$(realpath -m $BackupFolder)
    RootPath=$(realpath -m $RootPath)
    LogPath=$(realpath -m $LogPath)
}

# 获取参数
Options=$(getopt -o hBFRz -l help,backup,restore,backup-full -- "$@")
if [ ! $? -eq 0 ]
then
    echo "参数格式错误"
    exit 1
fi
# 格式化getopt的输出
eval set -- "$Options"

# 主程序
while true # 这个循环只应该检测到一次可以执行的项，在每个项后面都应该写上 break 或 exit
do
    case $1 in
        -B | --backup)
            init $@
            # 普通备份模式
            # 等待用户最终确认
            read -p "备份 $RootPath 到 $BackupFolder [按回车确认]"
            # 第一次用add模式创建的tar文件名字里有"all"所以才这么写的，不要改（当然最终都能实现啦）
            if [ -f $BackupFolder/$(cat $BackupFolder/.now_back)/snapshot ]
            then
                shift
                backup add $1
            else
                shift
                backup all $1
            fi
            break
        ;;
        -F | --backup-full)
            init $@
            # 完整备份模式
            # 等待用户最终确认
            read -p "重新完整备份 $RootPath 到 $BackupFolder [按回车确认]"
            shift
            backup all $1
            break
        ;;
        -R | --restore)
            init $@
            # 调用备份函数
            restore
            break
        ;;
        -h | --help)
            cat $ShellFilePath/help_info
            exit
        ;;
        --)
            echo "没有执行任何参数"
            exit 1
        ;;
        ?)
            echo "未知参数 $1"
            exit 1
        ;;
    esac

    shift
done
