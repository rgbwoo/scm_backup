#!/bin/sh

test -x /usr/bin/svnadmin || { echo "svnadmin need be installed."; exit 1; }

# 帮助函数
help(){
	echo "./svndump.sh [option]";
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

timestamp=$(date +%Y%m%d%H%M%S)
# 创建存放备份文件的临时目录
if [ ! -d $DUMPTO_DIR/$timestamp ]; then
	mkdir -p $DUMPTO_DIR/$timestamp
fi

# 创建存放备份的日志目录
if [ ! -d $DUMPTO_DIR/logs ]; then
	mkdir -p $DUMPTO_DIR/logs
fi

# 创建存放备份文件的目录
if [ ! -d $DUMPTO_DIR/backups ]; then
	mkdir -p $DUMPTO_DIR/backups
fi

cd $SVN_HOME
files=`ls`
for f in $files; do
	# echo $f;
	
	# 备份配置文件
	mkdir -p ${DUMPTO_DIR}/${timestamp}/${f}/conf
	cp -R ${SVN_HOME}/${f}/conf ${DUMPTO_DIR}/${timestamp}/${f}/conf
	
	# 获取最新的版本号
	cur_rev=`svnlook youngest ${SVN_HOME}/${f}`
	
	if [ -f $DUMPTO_DIR/logs/$f.log ]; then
		# 获取到上次备份的版本号
		last_rev=`cat $DUMPTO_DIR/logs/$f.log`
	else
		# 还未备份过，进行全量备份
		svnadmin dump ${SVN_HOME}/${f} > ${DUMPTO_DIR}/${timestamp}/${f}/dump_${cur_rev}.back
		# 记录备份的版本号
		echo -n $cur_rev > $DUMPTO_DIR/logs/$f.log
		continue
	fi
	# 计算此次备份和上次备份的版本号是否相同
	if [ $last_rev -lt $cur_rev ]; then
		# 进行增量备份
		last_rev=`expr $last_rev + 1`	
		svnadmin dump ${SVN_HOME}/${f} -r ${last_rev}:${cur_rev} --incremental > ${DUMPTO_DIR}/${timestamp}/${f}/dump_${cur_rev}.back
		# 记录备份的版本号
		echo -n $cur_rev > $DUMPTO_DIR/logs/$f.log
		continue
	fi
done

# 将备份文件打包压缩
tar zcf $DUMPTO_DIR/backups/svn_$timestamp.tar.gz $DUMPTO_DIR/$timestamp
# 将备份文件拷贝到远程服务器上
scp -p $DUMPTO_DIR/backups/svn_$timestamp.tar.gz root@192.168.10.106:/root/backups/svn
# 清理文件
rm -rf $DUMPTO_DIR/$timestamp


