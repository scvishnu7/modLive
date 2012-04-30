echo -e "${h1}Installing Debian Packages${cdef}"

export HOME=/root
export LC_ALL=C

dpkg-divert --local --rename --add /sbin/initctl
ln -f -s /bin/true /sbin/initctl

echo -e "${h2}Configure dpkg to Pending${cdef}"
dpkg --configure -a

echo -e "${h2}Installing the DEB Package${cdef}"
dpkg -i /tmp/*deb

echo -e "${h2}Installing its dependecies${cdef}"
apt-get install -f -y -q

echo -e "${h2}Cleanup${cdef}"
dpkg-divert --remove /sbin/initctl
rm -f /etc/debian_chroot
rm -f /sbin/initctl

