#set -e
set -u

source "$wd/functions"

echo $mnt
echo $wd
_unmountISO
exit

echo -e "$msg_extract"

function scan_iso {
	echo -e "${h1}${cDef}Scanning ... ${cdef}";
	rvalue=`basename $img`
	no=`file * | grep "# ISO" | wc -l`

	if [ "$no" = "0" ]; then
		echo -e "${h1}No ISO image found!${cdef}"
		echo -e "${h2}Pls try to put a ISO image file in $WD directory and try again${cdef}"
	elif [ $no = "1" ]; then
		value=`file * | grep "# ISO" | cut -d":" -f1`
		sed -i "s/$rvalue/$value/" "$wd/settings.conf"
		exit
	fi

	file * |
	awk  -F":" '
		/# ISO/ {
			x++
			printf "\t" x ". " $1 "\n"
		}
		END {
			print "Found " x " ISO 9660 CD-ROM."
			printf "choose [1-" x "]: "
		}
	'
	read

	value=`
		file * |
		awk  -F":" '
			/# ISO/ {
				x++
				printf x ". " $1 "\n"
			}
		' | sed "$REPLY!d" | cut -b1,2,3 --complement
		`
	sed -i "s/$rvalue/$value/" "$wd/settings.conf" # can't parse full path coz slash
	echo "ISO added"
	exit;
}

## check of arguments # disable feature due to unknown stuff
#	if [ $# -gt 0 ]; then
#		sed "s/$img/$@/" "$wd/settings.conf"
#		exit;
#	fi


# Image Verification
	if [ ! -e "$img" ]; then
		echo -e "${error}ISO image doesn't exists as defined in settings.conf${cdef}";
		while true; do
			echo -en "Do want modiso to try Detecting? (y/n): "; read;
			if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
				scan_iso;
				break;
			elif [ "$REPLY" = "n" ] || [ "$REPLY" = "N" ]; then
				exit;
			fi
		done
	fi

	if [ -d "$wd/custom" ]; then # clean
		echo -e "${h1}Old files found${cdef}";
		_clean
	fi

echo -e "${h1}Mounting ISO${cdef}"
	mkdir -p "$mnt"
	mount -o loop "$img" "$mnt"
	if [ $? != "0" ]; then
		_clean
		echo -e "${error}Unable to mount $mnt${cdef}"
		exit
	fi

	if [ ! -d "$mnt/.disk" ] || [ ! -d "$mnt/isolinux" ]; then
		echo -e "${error}Invalid ISO image.${cdef}";
		_clean
		exit
	fi

echo -e "${h1}Checking Architecture${cdef}"
	_arch="`uname -m`";
	if [ "$_arch" = "x86_64" ]; then
		_arch="amd64"
	fi

	grep $_arch "$mnt/.disk/info" > /dev/null;
	if [ $? = 1 ]; then
		echo -e "${error}Architecture Mismatch!${cdef}"
		_clean
		exit
	fi


echo -e "${h1}Extracting FileSystem${cdef}"
	if [ ! -e "$mnt/casper/filesystem.squashfs" ]; then
		echo -e "${error}Missing compressed filesystem${cdef}";
		_clean
		exit
	fi
	mkdir -p $fsys
	unsquashfs -f -d "$fsys" "$mnt/casper/filesystem.squashfs"
	if [ $? != "0" ]; then
		_clean
		echo -n "${error}Unable to extract the filesystem.squashfs${cdef}"
		exit
	fi


echo -e "${h1}Copying ISO files${cdef}"
	mkdir -p $iso
	sed -i '/^$/d' "$wd/primary/exclude.lst"
	rsync -a --exclude-from="$wd/primary/exclude.lst" "$mnt/" "$iso"

echo -e "${h1}Unmounting ISO${cdef}"
	_unmountISO

