# 文件夹备份脚本

这算是一个学习用的脚本了，各种地方写得都应该很差，咕咕

## 能干什么

一个（一堆）备份目录到tar文件的脚本\
支持tar的增量备份模式（不会记录删除有什么用呢）

## 使用

运行 `src/` 中的 `main.sh`，没有默认操作，需要参数\
用`-h | --help`查看帮助信息

虽然脚本文件很多但主脚本中有检测文件本身路径的逻辑，不用担心不再脚本根目录执行会无法加载其他函数的问题

> 打包和解包前后都有提示信息，不会直接执行的

## 备份格式

未来可能有其他的方式吧

### tar

> 使用`--one-file-system`参数，不会打包正常根目录里的`dev`这类文件夹

```text
.
├── backup
│   ├── 1699729938_2023-11-12_03-12-18
│   │   ├── 1699729939_2023-11-12_03-12-19_backup.tar
│   │   ├── .log
│   │   ├── .snapshot
│   │   └── .template
│   ├── 1699729941_2023-11-12_03-12-21
│   │   ├── 1699729941_2023-11-12_03-12-21_backup.tar
│   │   ├── 1699730061_2023-11-12_03-14-21_backup.tar
│   │   ├── .log
│   │   ├── .snapshot
│   │   └── .template
│   ├── .log
│   │   └── running.log
│   └── .now_backup
└── test
    ├── .a
    ├── a
    ├── b
    ├── c
    ├── dev
    └── lost+found
```

## 配置

### 强制使用root权限

可以在执行脚本前检查是否为root权限\

```shell
# normal
NeedRoot=0
```

### 备份路径

`BackupFolder`是要存放备份文件的根路径\
`RootPath`是要备份的目录

> 所有目录都可以使用相对路径（相对于那堆脚本文件）

```shell
# path
BackupFolder=../devtest/backup
RootPath=../devtest/test
```

### tar增量备份

强制每次备份使用完整备份\
关闭=不使用tar增量备份模式（-g 参数）\

```shell
# normal
Tar_Default_Full_Backup=0
```

### 日志目录

设置日志存放的目录（目前没什么有用的信息啦）

```shell
# log
RunningLogPath=../devtest/backup/.log
```

## 怪问题们

- 为什么不把东西都放到一起呀，这样多乱
  - 那就彻底看不懂了啊w
  - 还有...懒，反正有配置文件在两个文件和一堆文件也没什么区别嘛
- 为什么注释用中文，各种变量名用英文还写得稀烂
  - 因为不会英语所以要练嘛，那既然不会注释还写英文那我还写它干什么
- 就是压缩解压一下怎么写了这么一大坨东西出来
  - 最开始是想写一个类似于定期备份系统的脚本，弄了半天才发现tar没法记录文件的删除，但已经写了按顺序解压的逻辑了就顺便把其他的东西完善一下，反正也是在学东西嘛
