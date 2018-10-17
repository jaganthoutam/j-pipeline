#!/bin/bash
# production-tests.sh
echo "Starting production tests..."
echo "Testing root path..."
res1=$(curl -s http://$1/)
if [ "$res1" != "This is homepage" ]; then
	echo "Path / test failed. Aborting..."
	exit 1
fi

echo "Testing path /dir1 ..."
res2=$(curl -s http://$1/dir1)
if [ "$res2" != "Welcome to dir1, how can I help you ?" ]; then
	echo "Path /dir1 test failed. Aborting..."
	exit 1
fi

echo "Testing root path /dir2/person/1 ..."

res3=$(curl -s http://$1/dir2/person/1)
if [ "$res3" != "The information about person with id 1 is X" ]; then
	echo "Path /dir1 test failed. Aborting..."
	exit 1
fi

echo "Production tests succeeded."