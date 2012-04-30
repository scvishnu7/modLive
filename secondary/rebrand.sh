set -u

source "$wd/functions"
_getinfo

echo -e "****${cBro}Rebranding ISO${cdef}****"

echo -e "${h1}Install Menu${cdef}"
	sed -i "s/$id/Kiosk/" "$iso/isolinux/text.cfg"

echo -e "${h1}Creating README.diskdefines${cdef}"
	cat > "$iso/README.diskdefines" << EOF
#define DISKNAME  $id $release "$codefname" - Release $arch
#define TYPE  binary
#define TYPEbinary  1
#define ARCH  $arch
#define ARCH$arch  1
#define DISKNUM  1
#define DISKNUM1  1
#define TOTALNUM  0
#define TOTALNUM0  1
EOF

echo -e "${h1}Creating disk info${cdef}"
	echo "Kiosk $release "$codefname" - Release $arch (`date "+%Y%m%d"`)" > "$iso/.disk/info"

echo -e "${h1}Modify Live Session${cdef}"
	echo -e "${h2}Modify Live Users${cdef}"
	sed -i '
		s/\(USERNAME\)=".*"/\1="kiosk"/;
		s/\(HOST\)=".*"/\1="pitstop"/
		s/\(BUILD_SYSTEM\)=".*"/\1="Pitstop Kiosk"/
		' "$fsys/etc/casper.conf"

echo -e "${h2}Boot Choice${cdef}"
	echo -e "${h3}Modify Splash${cdef}"
	cp "$wd/theme/splash.pcx" "$iso/isolinux"

	echo -e "${h3}Remove Boot langlist${cdef}"
	echo -e "en\nne" > "$iso/isolinux/langlist"

