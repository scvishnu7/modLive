#set -e
set -u

source "$wd/functions"

echo -e "$msg_inject"

function deb {
	echo -e "${h1}Injecting Debian Packages${cdef}"
	flag=0;
	for i in `find $deb -name *deb`; do
		flag=1;
		echo -e "\t" $(basename $i)
		cp "$i" "$fsys/tmp/";
	done

	if [ "$flag" = 0 ]; then
		echo -e "${error}No packages found${cdef}"
	else
		cp "$wd/gscript/deb.sh" "$fsys/tmp/"
	fi
}

function mysql {
	echo -e "${h1}Injecting MySQL${cdef}"
	if [ "`ls $wd/mysqlhere`" = "" ]; then
		echo -e "${error}No packages found${cdef}"
	else
		for i in "$wd/mysqlhere/"*; do
			echo -e "\t" $(basename $i)
			cp $i "$fsys/var/cache/apt/archives/";
		done

		cp "$wd/gscript/mysql.sh" "$fsys/tmp/"
		pass=`sed '/root_password_again/!d; s/.* select \(.*\) |.*/\1/' "$wd/custom/FileSystem/tmp/mysql.sh"`

		echo -e "${h1}Default mysql root password:${cDef} $pass${cdef}";
	fi
}

function mysqlpass {
	if [ -e "fsys/tmp/mysql.sh" ]; then
		echo -e "${warn}should be used with mysql";
	else
		echo -en "${h2}Enter the new password${cdef}:${cDef} ";
		read
		echo -en "${cdef}";
		sed -i "s/$pass/$REPLY/g" "$wd/custom/FileSystem/tmp/mysql.sh"
	fi
}

function egg {
	echo -e "${h1}Injecting Python egg${cdef}"
	if [ "`ls $wd/egghere`" = "" ]; then
		echo -e "${error}No egg found${cdef}"
	else
		for i in "$wd/egghere/"*; do
			echo -e "\t" $(basename $i)
			cp "$i" "$fsys/tmp/";
		done

		cp "$wd/gscript/egg.sh" "$fsys/tmp/"
		sed '/^$/d' -i "$wd/gscript/egglist"
		cp "$wd/gscript/egglist" "$fsys/tmp/"
	fi

}

# cleanup old file
	if [ "`ls $fsys/tmp`" != "" ]; then
		flag=0;
		for i in "$fsys/tmp/"*; do
			if [ $flag = "0" ]; then
				flag=1;
				echo -e "${h1}Old files found: ${cdef}Removing";
			fi
			echo -e "${h3}$(basename $i)${cdef}"
			rm -rf "$i"
		done
	fi

# arg parser
	if [ $# -lt 1 ]; then
		echo -e "${h1}Injection Nothing${cdef}";
		exit;
	fi
	for arg in "$@"; do
		case $arg in
			deb) deb;;
			mysql) mysql;;
			--pass) mysqlpass;;
			egg) egg;;
			*) echo -e "${error}Unrecognized argument $arg ${cdef}";;
		esac
	done

