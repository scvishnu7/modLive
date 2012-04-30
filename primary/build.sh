#set -e
set -u

source "$wd/functions"
_getinfo

echo -e "$msg_build"

# Remove old stuffs
	flag=0;
	sed -i '/^$/d' "$wd/primary/exclude.lst" # remove blank
	while read i; do
		if [ -e "$iso/$i" ]; then
			if [ $flag = "0" ]; then
				flag=1;
				echo -e "${h1}Old files found${cdef}";
			fi
			echo -e "${h2}Deleting ${i}${cdef}"
			rm -f "$iso/$i"
		fi
	done < "$wd/primary/exclude.lst"

echo -e "${h1}Cleanup${cdef}"
	rm -f "$fsys/etc/debian_chroot"
	rm -f "$fsys/etc/hosts"
	rm -f "$fsys/etc/resolv.conf"
	rm -f "$fsys/var/cache/apt/archives/"*.deb
	rm -f "$fsys/var/cache/apt/archives/partial/"*
	rm -rf "$fsys/home/*"
	rm -f "$fsys/boot/"*.bak
	rm -f "$fsys/var/lib/dpkg/"*-old
	rm -f "$fsys/var/lib/aptitude/"*.old
	rm -f "$fsys/var/cache/debconf/"*.dat-old
	rm -f "$fsys/var/log/"*.gz
	rm -rf "$fsys/tmp/"*


echo -e "${h1}Assembling FileSystem${cdef}"


echo -e "${h2}Compressing FileSystem${cdef}"
	mksquashfs "$fsys" "$iso/casper/filesystem.squashfs"
	if [ $? != 0 ]; then
		echo -n "${error}Unable to compress the filesystem.squashfs${cdef}"
		exit
	fi

echo -e "${h2}Creating filesystem.manifest${cdef}"
	chroot "$fsys" dpkg-query -W --showformat='${Package} ${Version}\n'\
		> "$iso/casper/filesystem.manifest"
	if [ $? != 0 ]; then # chroot fallback
		echo -n "${error}Unable to create filesystem.manifest${cdef}"
		exit
	fi

echo -e "${h2}Creating filesystem.manifest-desktop${cdef}"
	cp -f "$iso/casper/filesystem.manifest" "$iso/casper/filesystem.manifest-desktop"
	REMOVE='ubiquity casper'
	for i in $REMOVE; do
		sed -i "/${i}/d" "$iso/casper/filesystem.manifest-desktop";
	done

echo -e "${h2}Creating filesystem.size${cdef}"
	(du -sx --block-size=1 $fsys | cut -f1) > "$iso/casper/filesystem.size"

echo -e "${h1}Creating MD5Sums${cdef}"
	cd "$iso"
	(find -type f -print0 | xargs -0 md5sum | grep -v "isolinux/boot.cat") > md5sum.txt

echo -e "${h1}Creating ISO${cdef}"
	rm -f "$wd/Custom-$id-$release-$arch.iso"
	genisoimage -r -V "Custom-$id-$release-$arch" \
		-b isolinux/isolinux.bin -c isolinux/boot.cat -cache-inodes \
		-J -l -no-emul-boot -boot-load-size 4 -boot-info-table \
		-o "$wd/Custom-$id-$release-$arch.iso" -input-charset utf-8 .
	if [ $? != 0 ]; then
		echo -n "${error}Failed to create ISO image${cdef}"
		exit
	fi

	chmod 555 "$wd/Custom-$id-$release-$arch.iso"
	echo -e "${h1}Successfuly created ISO image${cdef}";

