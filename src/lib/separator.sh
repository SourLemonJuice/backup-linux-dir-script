# 分隔线函数
llib_separator(){
    if [[ -z $1 ]] || [[ ! ${#1} -eq 1 ]]; then
        Character='='
    else
        Character=$1
    fi

    ShellWidth=$(stty size|awk '{print $2}')
    yes "$Character" |sed $ShellWidth'q' |tr -d "\n" && echo 
}
