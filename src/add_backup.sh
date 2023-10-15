#!/bin/bash

BackupFolder=$1
RootPath=$2

cd $RootPath
tar -g $BackupFolder/$(cat $BackupFolder/.now_back)/snapshot -zcvf $BackupFolder/$(cat $BackupFolder/.now_back)/$(date +%Y-%m-%d_%H-%M-%S)_backup.tar.gz --exclude=lost+found --exclude=/sys --exclude=/proc --exclude=/boot --exclude=/dev --exclude=/mnt .
