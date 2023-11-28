#!/bin/bash

# 获取脚本真实路径
ShellFilePath=$( cd $(dirname $0) || exit 1 && pwd)

# 读取配置文件
# 检测用户配置目录下是否有文件，如果有就循环读取（这个检测方式真垃圾）
if [[ -d $ShellFilePath/config.d && ! -z $(ls $ShellFilePath/config.d) ]]; then
    # 循环读取目录下的配置文件
    for i in $ShellFilePath/config.d/*;do
        source $i
        # 如果没能加载就退出
        if [ ! $? -eq 0 ]; then
            echo 没能加载 $i && exit 1
        fi
    done
fi
# 相对路径改绝对路径
{
    cd $ShellFilePath || exit 1
    BackupFolder=$(realpath -m $BackupFolder)
    RootPath=$(realpath -m $RootPath)
    LogPath=$(realpath -m $LogPath)
}
# 日志函数
source $ShellFilePath/lib/logger.sh && logger file "已加载日志函数"
# 初始化日志文件
logger 'init'

# 加载一些小东西
# 输出数组内容
source $ShellFilePath/lib/println_array_items.sh && logger file "已加载读出数组函数"
# 打印分割线
source $ShellFilePath/lib/separator.sh && logger file "已加载分割线函数"
# 读取初始化函数
source $ShellFilePath/init.sh && logger file "已加载初始化函数"
# 读取备份逻辑函数
source $ShellFilePath/backup.sh && logger file "已加载备份逻辑函数"
# 读取恢复函数
source $ShellFilePath/restore.sh && logger file "已加载恢复逻辑函数"

# 获取参数
Options=$(getopt -o vhBRzf -l version,help,backup,restore,full-backup -- "$@")
# 获取失败则退出
[ ! $? -eq 0 ] && logger both "参数格式错误" "参数格式错误 $@" && exit 1
# 格式化getopt的输出
eval set -- "$Options" || exit 1

# 主程序
logger 'file' "函数加载完成"
# 这个循环只应该检测到一次可以执行的项，在每个项后面都应该写上 break 或 exit
while true
do
    case $1 in
        -B | --backup)
            init $@ && logger 'file' "init函数执行"
            # 普通备份模式
            # 第一个判断检测当前是否有已经存在的备份组，第二个判断读取配置文件来决定是否强制完全备份
            if [[ -f $BackupFolder/$Now_Backup/.tar_snapshot ]] && [[ $Tar_Default_Full_Backup -eq 0 ]]
            then
                backup 'add' $2
            else
                backup 'full' $2
            fi
            break
        ;;
        -F | --full-backup)
            init $@ && logger 'file' "init函数执行"
            # 完整备份模式
            backup 'full' $2
            break
        ;;
        -R | --restore)
            init $@ && logger 'file' "init函数执行"
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
            # 打印一个提示信息
            cat $ShellFilePath/help_info
            exit
        ;;
        ?)
            echo "未知参数 $1"
            exit 1
        ;;
    esac
    shift
done
