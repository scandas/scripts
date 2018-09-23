#!/bin/bash

DATADIR=/home/andro/.data_android
LOWERDIR=$DATADIR/squash
UPPERDIR=$DATADIR/upper
WORKDIR=$DATADIR/work
OVERLAYDIR=/home/andro/android
SQUASHCYANOGEN=android_CM11_source-lz4.sq
SQUASHLINEAGE=android_lineageos-cm11-lz4.sq

function setup-lineage {
	sudo mount -o ro $DATADIR/$SQUASHLINEAGE $LOWERDIR
	sudo mount -t overlay ccache_overlay -o lowerdir=$LOWERDIR,upperdir=$UPPERDIR,workdir=$WORKDIR $OVERLAYDIR
}

function setup-cyanogen {
	sudo mount -o ro $DATADIR/$SQUASHCYANOGEN $LOWERDIR
	sudo mount -t overlay ccache_overlay -o lowerdir=$LOWERDIR,upperdir=$UPPERDIR,workdir=$WORKDIR $OVERLAYDIR
}

function stop {
	if [[ `status` == "It's mounted." ]] ;then 
		sudo umount -l $OVERLAYDIR
		sudo umount -l $LOWERDIR
	fi
}

function update {
	echo "Isn't implemented jet."
	if [[ `status` == "not implemented" ]] ;then 
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
	#du -sh $UPPERDIR
	if grep -qs "$OVERLAYDIR " /proc/mounts; then
		echo "It's mounted."
	else
		echo "It's not mounted."
	fi
}

case "$1" in
	setup-lineage)
		setup-lineage
		;;
	stop)
		setup-cyanogen
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
            echo $"Usage: $0 {setup-lineage|setup-cyanogen|restart|update|status}"
            exit 1
 
esac
