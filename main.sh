#!/bin/bash
#set -e
set -u

export wd="`pwd`/`dirname $0`"

# removing relative path # I became insane at this point
	wd=`echo $wd | sed 's/\/\.$//g'` # remove /.
	wd=`echo $wd | sed 's/\/\.\//\//g'` # remove /./
	wd=`echo $wd | sed 's/\/\.\//\//g'` # remove /./ when removed /./

	while true; do
		wd=`echo $wd | sed 's/\/[^\/]*\/\.\.//'`
		echo $wd | grep "\.\." > /dev/null
		if [ $? == "1" ]; then
			break
		fi
	done

source "$wd/settings.conf"
source "$wd/functions"

function inf {
	echo "$name version $version"
	echo -e "$year by $author"
#	echo $warranty
}

function Usage {
	inf
	echo -e "\nUsage: \t`basename $0` [Option]";
	echo -e "\t-e|--extract\tExtract image"
	echo -e "\t-l|--list\tList changes to be applied"
	echo -e "\t-a|--apply\tApply all listing"
	echo -e "\t-b|--build\tBuild the image"
#	echo -e "\t-B|--Build\tBuild ISO with out compression"
	echo -e "\t-r|--rebrand\tRebrand ISO image"
	echo -e "\t-v|--version\tShow version"
	echo -e "\t-h|--help\tDisplay this message"
}

# checking arguments
	if [ $# -eq 0 ]; then
		Usage;
		exit;
	fi

# superuser bypass help
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
		Usage
		exit;
	fi

# check_superuser
	if [ "$USER" != "root" ]; then
		echo -e "${cred}Superuser Privileges Requried!"
		exit
	fi


case $1 in
	-e|--extract) exec "$wd/primary/extract.sh";;
	-l|--list|-i|--inject) exec "$wd/primary/inject.sh" `argpass $@`;;
	-a|--apply|-m|--melt) exec "$wd/primary/melt.sh";;
	-b|--build) exec "$wd/primary/build.sh";;
	-B|--Build) exec "$wd/secondary/build.sh";;

	-r|--rebrand) exec "$wd/secondary/rebrand.sh";;

	-v|--version) inf ;;
	*) echo -e "${error}Unrecognized argument '$1'${cdef}" ;;
esac

