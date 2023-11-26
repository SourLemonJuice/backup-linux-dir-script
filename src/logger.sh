
# 写日志咯
logger(){
    LogName=running.log
    
    # 创建log文件夹
    if [[ ! -d $RunningLogPath ]]; then
            logger 'file' "$(mkdir -vp $RunningLogPath || exit 1)"
    fi

    case $1 in
    both)
        echo $2
        if [[ -z $3 ]];then
            echo "[$(date +%T)] [$1] $2" >> $RunningLogPath/$LogName
        else
            # 如果有第三个参数就向文件内写入单独的内容
            echo "[$(date +%T)] [$1] $3" >> $RunningLogPath/$LogName
        fi
    ;;
    term)
        echo $2
    ;;
    file)
        echo "[$(date +%T)] [$1] $2" >> $RunningLogPath/$LogName
    ;;
    init)
        # 清空日志
        > $RunningLogPath/$LogName || exit 1
        # 写入日志
        logger 'file' "$(date +%s_%Y-%m-%d_%T) $0"
    ;;
    *)
        # 保留缺省情况
        echo $@
        echo "[$(date +%T)] $@" >> $RunningLogPath/$LogName
    ;;
    esac
}
