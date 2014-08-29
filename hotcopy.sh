#!/bin/sh

test -x /usr/bin/svnadmin || { echo "svnadmin need be installed."; exit 1; }

# 帮助函数
help(){
	echo "./hotcpoy.sh [option]";
	exit 0;
}

# SVN 的目录
SVN_HOME=$SVNHOME

# 备份工作目录
DUMPTO_DIR=`pwd`

# 获取参数
while [ -n "$1" ]; do
	case $1 in
		-h) help; shift 1;;
		-s) SVN_HOME=$2; shift 2;;
		-d) DUMPTO_DIR=$2; shift 2;; 
		-*) echo "error: no such option $1. -h for help";exit 1;;
		*) break;;
	esac
done

test -d $DUMPTO_DIR || { echo "please set BACKDIR"; exit 1; }
test -d $SVN_HOME || { echo "please set SVNHOME"; exit 1; }

echo "================================================="
echo "Dump Directory = $DUMPTO_DIR"
echo "SVN Repository = $SVN_HOME"
echo "================================================="

date=$(date +%Y%m%d)

# 创建存放备份文件的目录
# 创建存放备份文件的目录
if [ ! -d $DUMPTO_DIR/backups ]; then
	mkdir -p $DUMPTO_DIR/backups
fi
if [ -d $DUMPTO_DIR/hotcopy ]; then
	rm -rf $DUMPTO_DIR/hotcopy
fi
mkdir -p $DUMPTO_DIR/hotcopy

cd $SVN_HOME
files=`ls`
for f in $files; do
	mkdir -p $DUMPTO_DIR/hotcopy/${f}
	svnadmin hotcopy $SVN_HOME/${f} $DUMPTO_DIR/hotcopy/${f}
done

# 将备份文件打包压缩
tar zcf $DUMPTO_DIR/backups/full_${date}.tar.gz $DUMPTO_DIR/hotcopy
# 将备份文件拷贝到远程服务器上
scp -p $DUMPTO_DIR/backups/full_${date}.tar.gz root@192.168.10.106:/root/backups/svn
# 清理文件
rm -rf $DUMPTO_DIR/hotcopy
