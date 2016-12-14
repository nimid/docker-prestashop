#!/bin/bash

if [ -z "$1" ]; then
	echo "Please specify the version of PrestaShop"
	echo "Example: ./start.sh 1.6.0.1"
	exit
fi

version=$1
minor_version=${version:2:1}
port="${version//./}"
local_directory=images/$version/prestashop
local_file=images/$version/prestashop_$version.zip

if [ ! -f $local_file ]; then
    wget https://www.prestashop.com/download/old/prestashop_$version.zip -O $local_file
fi

# Build
echo "Recreating local directory"
rm -rf $local_directory
mkdir $local_directory

echo "Extracting prestashop_$version.zip"
unzip -oq $local_file -d $local_directory

echo "Building docker image for PrestaShop version $1"
docker build -t prestashop/prestashop:$version images/$version/.

# Run
if test $minor_version -lt 7; then
	host_source=$PWD/$local_directory/prestashop/
else
	host_source=$PWD/$local_directory
fi

chmod -R a+rwx $host_source

docker run --name prestashop-$version -d -v $host_source:/var/www/html -p $port:80 prestashop/prestashop:$version
