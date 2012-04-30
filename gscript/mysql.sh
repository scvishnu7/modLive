echo -e "${h1}Installing MySQL Packages${cdef}"

export HOME=/root
export LC_ALL=C

echo -e "${h2}Installing the DEB Package${cdef}"
echo mysql-server mysql-server/root_password select toor | debconf-set-selections
echo mysql-server mysql-server/root_password_again select toor | debconf-set-selections
yes | apt-get install mysql-server
yes | apt-get install mysql-client

