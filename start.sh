#!/bin/sh

if [ -z "$1" ]; then
	echo "Please specify the version of PrestaShop"
	echo "Example: ./start.sh 1.6.0.1"
	exit
fi

version=$1
minor_version=${version:2:1}
port="${version//./}"

# Build
echo "Recreating local directory"
rm -rf images/$version/prestashop/
mkdir images/$version/prestashop/

echo "Extracting prestashop_$version.zip"
unzip -oq images/$version/prestashop_$version.zip -d images/$version/prestashop

echo "Building docker image for PrestaShop version $1"
docker build -t prestashop/prestashop:$version images/$version/.

# Run
if test $minor_version -lt 7; then
	host_source=$PWD/images/$version/prestashop/prestashop/
else
	host_source=$PWD/images/$version/prestashop/
fi

docker run --name prestashop-$version -d -v $host_source:/var/www/html -p $port:80 prestashop/prestashop:$version