#!/bin/bash
# 欢迎光临(=・ω・=)
# 别说什么颜文字可能不兼容，这里可全是utf8的中文

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
source $ShellFilePath/lib/logger.sh
# 初始化日志文件
llib_logger 'init'
llib_logger 'file' "已初始化 日志函数"

# 加载一些小东西
# 输出数组内容
source $ShellFilePath/lib/println_array_items.sh && llib_logger file "已加载 读出数组函数"
# 打印分割线
source $ShellFilePath/lib/separator.sh && llib_logger file "已加载 分割线函数"
# 读取初始化函数
source $ShellFilePath/init.sh && llib_logger file "已加载 初始化函数"
# 读取备份逻辑函数
source $ShellFilePath/backup.sh && llib_logger file "已加载 备份逻辑函数"
# 读取恢复函数
source $ShellFilePath/restore.sh && llib_logger file "已加载 恢复逻辑函数"

# 获取参数
Options=$(getopt -o vhBRzf -l version,help,backup,restore,full-backup -- "$@")
# 获取失败则退出
[ ! $? -eq 0 ] && llib_logger both "参数格式错误" "参数格式错误 $@" && exit 1
# 记录处理后用户输入的参数
llib_logger 'file' "整理输入参数成功，整理后用户输入的参数列表为 [$@]"
# 格式化getopt的输出
eval set -- "$Options" || exit 1

# 这个循环只应该检测到一次可以执行的项，在每个项后面都应该写上 break 或 exit
llib_logger 'file' "进入 简单逻辑 参数检测循环"
while true;
do
    case $1 in
        -h | --help)
            llib_logger 'file' "打印帮助信息"
            cat $ShellFilePath/help_info
            exit
        ;;
        -v | --version)
            llib_logger 'file' "打印版本号"
            cat $ShellFilePath/version
            exit
        ;;
        --)
            llib_logger 'file' "无参数输入，打印帮助信息"
            # 打印一个提示信息
            cat $ShellFilePath/help_info
            exit
        ;;
        *)
            llib_logger 'file' "参数不是小功能，准备进入第二个环境的循环"
            break
        ;;
    esac
done

llib_logger 'file' "进入 需要改动文件 的参数检测循环"

# 初始化需要备份的仓库位置
init $@ && llib_logger 'file' "init函数执行"
# 这里还是用break吧，说不定回头会在下面干什么呢
while true
do
    case $1 in
        -B | --backup)
            # 普通备份模式
            llib_logger 'file' "进入普通备份模式"
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
            # 强制完整备份模式
            llib_logger 'file' "进入强制完整备份模式"
            backup 'full' $2
            break
        ;;
        -R | --restore)
            llib_logger 'file' "进入恢复模式"
            # 调用备份函数
            restore $2
            break
        ;;
        *)
            llib_logger 'file' "第二个循环输入了未知参数 $1"
            exit 1
        ;;
    esac
    shift
done

llib_logger 'file' "脚本执行完毕"
