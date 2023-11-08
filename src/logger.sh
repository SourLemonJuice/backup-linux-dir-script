
# 写日志咯
logger(){
    case $1 in
    both)
        echo $2
        echo "[$(date +%T)] [$1] $2" >> $RunningLogPath/$LogName
    ;;
    term)
        echo $2
    ;;
    file)
        echo "[$(date +%T)] [$1] $2" >> $RunningLogPath/$LogName
    ;;
    *)
        # 保留缺省情况
        echo $@
        echo "[$(date +%T)] $@" >> $RunningLogPath/$LogName
    ;;
    esac
}
