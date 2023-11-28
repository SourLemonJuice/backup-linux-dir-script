
# 写日志咯
logger(){
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
    init)
        # 检测并创建log文件夹
        if [[ ! -d $LogPath ]]; then
                logger 'file' "$(mkdir -vp $LogPath || exit 1)"
        fi
        # 清空日志
        > $LogPath/$LogName || exit 1
        # 写入日志
        logger 'file' "$(date +%s_%Y-%m-%d_%T) $0"
    ;;
    *)
        # 保留缺省情况
        echo $@
        echo "[$(date +%T)] $@" >> $LogPath/$LogName
    ;;
    esac
}
