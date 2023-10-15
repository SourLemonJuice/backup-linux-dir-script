#!/bin/bash

# 读取配置文件
source path.conf

# 相对路径改绝对路径
BackupFolder=$(cd $BackupFolder && pwd)
RootPath=$(cd $RootPath && pwd)

# 检测权限
if [  $(id -u) -eq 0 ]
then
    echo "需要root权限执行"
    exit 1
fi

# 创建备份文件的文件夹
if [ ! -d $BackupFolder ]
then
    mkdir -v $BackupFolder
fi

# 创建确定文件所在的组的编号文件
if [ ! -f $BackupFolder/.now_back ]
then
    echo $(date +%s) > $BackupFolder/.now_back
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
            # 等待用户最终确认
            read -p "备份 $RootPath [按回车确认]"
            # 第一次用full这个脚本文件的名字里有 all 所以才这么写的，不要改（当然最终都能实现啦）
            if [ -f $BackupFolder/$(cat $BackupFolder/.now_back)/snapshot ]
            then
                ./add_backup.sh $BackupFolder $RootPath
            else
                ./full_backup.sh $BackupFolder $RootPath
            fi
        ;;
        -B)
            read -p "完整备份 $RootPath [按回车确认]"
            # 更新编号
            echo $(date +%s) > $BackupFolder/.now_back
            ./full_backup.sh $BackupFolder $RootPath
        ;;
        -r)
            # 列出所有可用的备份组
            ls -tr $BackupFolder
            read -p "选择要从哪个文件恢复:" -a RestoreFolder
            if [ ! -d $BackupFolder/$RestoreFolder ]
            then
                echo "没有路径" && exit 13
            fi

            # 列出所有可用的备份
            ls -tr $BackupFolder/$RestoreFolder | grep backup.tar
            # 输入要使用的备份
            read -p "选择要从哪些文件恢复，用空格分开[靠前的文件会先被解压，请按照时间顺序填写]:" -a RestoreFile

            # 循环释放每个输入的文件
            for i in ${RestoreFile[@]}
            do
                # 如果没有文件则报错
                if [ ! -f $BackupFolder/$RestoreFolder/$i ]
                then
                    echo "没有路径" && exit 13
                fi
                # 解压文件
                tar -zxvf $BackupFolder/$RestoreFolder/$i -C $RootPath
            done
        ;;
        -h | --help)
            cat ./help_info
        ;;
        --)
            break
        ;;
        ?)
            echo "未知参数 $1"
            exit 12
        ;;
    esac

    shift
done
