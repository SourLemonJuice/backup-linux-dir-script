#!/bin/bash

# 获取脚本真实路径
ShellFilePath=$( cd $(dirname $0) || exit 1 && pwd)

# 读取配置文件
source $ShellFilePath/config
[ -f $ShellFilePath/config.d/* ] && source $ShellFilePath/config.d/* && echo loading
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
    RunningLogPath=$(realpath -m $RunningLogPath)
}

# 获取参数
Options=$(getopt -o vhBRzf -l version,help,backup,restore,backup-full -- "$@")
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
            # 第一个判断检测当前是否有已经存在的备份组，第二个判断读取配置文件来决定是否强制完全备份
            if [[ -f $BackupFolder/$Now_Backup/.snapshot ]] && [[ $Tar_Default_Full_Backup -eq 0 ]]
            then
                backup 'add' $2
            else
                backup 'full' $2
            fi
            break
        ;;
        -F | --backup-full)
            init $@
            # 完整备份模式
            backup 'full' $2
            break
        ;;
        -R | --restore)
            init $@
            # 调用备份函数
            restore $2
            break
        ;;
        -h | --help)
            cat $ShellFilePath/help_info
            exit
        ;;
        -v | --version)
            cat $ShellFilePath/version
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

