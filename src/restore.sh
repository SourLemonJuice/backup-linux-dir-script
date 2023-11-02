
restore(){

    # 列出所有可用的备份组，并写入 BackupFolderList
    for i in $(ls -1 ${BackupFolder}); do
        BackupFolderList[${#BackupFolderList[@]}]=$i
    done
    separator
    println_array_items ${BackupFolderList[@]}
    separator

    # 要恢复哪个备份组
    read -p "选择要从哪个备份组恢复:" -a RestoreFolderName
    if [ -z $RestoreFolderName ]; then
        RestoreFolderName=${BackupFolderList[0]}
        echo "空输入，已使用${RestoreFolderName}(最旧的备份组)"
    fi

    # 合并恢复文件夹的路径
    RestoreFolder="$BackupFolder/$RestoreFolderName"
    if [[ ! -d $RestoreFolder ]] || [[ -z $RestoreFolderName ]]; then
        echo "路径错误，或不存在"
        exit 1
    fi

    # 将文件夹内的文件写入数组 RestoreFolderFileList
    for i in $(ls -1 $RestoreFolder | grep backup.tar ); do
        RestoreFolderFileList[${#RestoreFolderFileList[@]}]=$i
    done

    # 列出所有可用的备份
    println_array_items ${RestoreFolderFileList[@]}
    # 要恢复到哪个时间点
    read -p "选择要恢复到那个备份的状态:" -a RestoreFileEnd
    # 如果没有文件则报错
    if [[ ! -f $RestoreFolder/$i ]] || [[ -z $RestoreFileEnd ]]; then
        echo "没有文件"
        exit 1
    fi

    # 筛选出要用的所有文件
    for i in "${RestoreFolderFileList[@]}"; do
        # 写入临时的列表
        RestoreFileList["${#RestoreFileList[@]}"]=$i
        # 处理到最后一个要写入的文件名是跳出
        if [ $RestoreFileEnd == $i ]; then
            break
        fi
    done

    # 输出即将释放的文件，并请求确认
    separator
    println_array_items "${RestoreFileList[@]}"
    separator
    read -p "即将从上到下还原这些文件 [按回车确定]"

    # 循环释放每个输入的文件
    for i in "${RestoreFileList[@]}";
    do
        logger "开始释放文件 $i"
        # 释放文件
        # TODO 在命令中覆盖rootpath
        tar -xvf $RestoreFolder/$i -C $RootPath
    done
}
