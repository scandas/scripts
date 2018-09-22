#!/bin/bash

DATADIR=/home/andro/.data_ccache
LOWERDIR=$DATADIR/squash
UPPERDIR=$DATADIR/upper
WORKDIR=$DATADIR/work
CCACHEDIR=/home/andro/.ccache
SQUASHFILE=ccache-lzo.sq

function start {
	sudo mount -o ro $DATADIR/$SQUASHFILE $LOWERDIR
	sudo mount -t overlay ccache_overlay -o lowerdir=$LOWERDIR,upperdir=$UPPERDIR,workdir=$WORKDIR $CCACHEDIR
}

function stop {
	sudo umount $CCACHEDIR
	sudo umount $LOWERDIR
}

function update {
	if [[ `status` == "It's mounted." ]] ;then 
		echo "updating..."
		cd $CCACHEDIR
		echo "creating $SQUASHFILE.tmp..."
		sudo mksquashfs ./ $DATADIR/$SQUASHFILE.tmp -comp lzo
		sudo chown $USER:$USER $DATADIR/$SQUASHFILE.tmp
		echo "unmounting..."
		stop
		if [ -e $DATADIR/$SQUASHFILE.old ]; then
			rm $DATADIR/$SQUASHFILE.old
		fi
		if [ -e $DATADIR/$SQUASHFILE ]; then
			mv $DATADIR/$SQUASHFILE $DATADIR/$SQUASHFILE.old
		fi
		mv $DATADIR/$SQUASHFILE.tmp $DATADIR/$SQUASHFILE
		echo "removing content of $UPPERDIR..."
		sudo rm -r $UPPERDIR/*
		echo "mounting..."
		start
	fi
}

function status {
	if grep -qs "$CCACHEDIR " /proc/mounts; then
		echo "It's mounted."
	else
		echo "It's not mounted."
	fi
}

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	status)
		status
		;;
	restart)
		stop
		start
		;;
	update)
		update
		;;
         
        *)
            echo $"Usage: $0 {start|stop|restart|update|status}"
            exit 1
 
esac
