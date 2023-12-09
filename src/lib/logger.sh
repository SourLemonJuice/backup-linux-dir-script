# 写日志咯
llib_logger(){
    LogPath=$LogPath
    LogName=$LogName

    case $1 in
    both)
        echo $2
        if [[ -z $3 ]];then
            echo "[$(date +%T)] [$1] $2" >> $LogPath/$LogName
        else
            # 如果有第三个参数就向文件内写入单独的内容
            echo "[$(date +%T)] [$1] $3" >> $LogPath/$LogName
        fi
    ;;
    term)
        echo $2
    ;;
    file)
        echo "[$(date +%T)] [$1] $2" >> $LogPath/$LogName
    ;;
    stdin)
        # 管道输入模式
        # 执行到这里tee就会开始请求标准输入，有输入后就会将内容附加到后面的文件里实现从管道输入读取命令输出
        tee -a $LogPath/$LogName
    ;;
    init)
        # 检测并创建log文件夹
        if [[ ! -d $LogPath ]]; then
                llib_logger 'file' "$(mkdir -vp $LogPath || exit 1)"
        fi
        # 清空日志
        > $LogPath/$LogName || exit 1
        # 写入日志
        llib_logger 'file' "$(date +%s_%Y-%m-%d_%T) $0"
    ;;
    *)
        # 保留缺省情况
        echo $@
        echo "[$(date +%T)] $@" >> $LogPath/$LogName
    ;;
    esac
}
