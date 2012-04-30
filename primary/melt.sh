#set -e
set -u

echo -e "$msg_chroot"

function recursive_umount {
	cat /proc/mounts | grep $fsys
	if [ $? = 1 ]; then
		exit
	fi

	for i in `awk -F' ' " $fsys { print $2 }" /proc/mounts`; do
		echo -e "${h2}Unmounting: ${cyel}`echo $i | sed "s@$wd/FileSystem@@g"`${cdef}"
		umount -fl "$i"
		if [ $? != "0" ]; then
			echo -e "${error}Unable to unmount $i. Try to unmount it manualy or reboot so you don't harm your host OS.${cdef}"
		fi
	done
}


# check script
	ls "$fsys/tmp" | grep sh$
	if [ $? != "0" ]; then
		echo -e "${h1}Nothing to do, try injecting first${cdef}"
		exit
	fi


echo -e "${h1}Mount Filesystem${cdef}"
	echo -e "${h2}Mounting${cdef}: /dev"
	mount --rbind /dev "$fsys/dev" || { echo -e "${error}Unable to mount /dev${cdef}"; exit; }
	echo -e "${h2}Mounting${cdef}: /proc"
	mount --bind /proc "$fsys/proc" || { echo -e "${error}Unable to mount /proc${cdef}"; exit; }
	echo -e "${h2}Mounting${cdef}: /sys"
	mount --bind /sys "$fsys/sys" || { echo -e "${error}Unable to mount /sys${cdef}"; exit; }

# for internet connection
#	cp -f /etc/hosts "$fsys/etc"
#	cp -f /etc/resolv.conf "$fsys/etc"

echo -e "${h1}Entering Chroot Mode${cdef}"
	echo chroot > "$fsys/etc/debian_chroot"

	for i in "$fsys/tmp/"*sh; do
		ii=$(basename $i);
		chroot "$fsys" bash /tmp/"$ii";
	done

	rm -f "$fsys/etc/debian_chroot"
	echo -e "${h1}Exiting Chroot Mode"

echo -e "${h1}Unmount Filesystem${cdef}"
	for i in 'proc' 'sys' 'dev'; do
		echo -e "${h2}Unmounting${cdef}: /$i"
		umount -fl "$fsys/$i"
		if [ $? != "0" ]; then
			echo -e "${error}Unable to mount /$i${cdef}";
		fi
	done

recursive_umount

