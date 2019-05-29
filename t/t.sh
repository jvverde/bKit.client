#!/usr/bin/env bash
set -e
trap 'rm -rf a' EXIT
mkdir -pv a/b
echo $RANDOM > a/b/c
echo $RANDOM > a/file
../bkit.sh .
sleep 1

echo -e "\n-----------------from file to directory-----------------"
rm -rf a/b/c
mkdir -pv a/b/c/
echo $RANDOM > a/b/c/d
../bkit.sh .
sleep 1

echo -e "\n-----------------from directory to symlink-----------------"
rm -rf a/b/c
ln -sr a/file a/b/c
../bkit.sh .
sleep 1

echo -e "\n-----------------from symlink to directory-----------------"
rm -rf a/b/c
mkdir -pv a/b/c/
echo $RANDOM > a/b/c/d
../bkit.sh .
sleep 1

echo -e "\n-----------------from directory to hardlink-----------------"
rm -rf a/b/c
ln a/file a/b/c
../bkit.sh .
sleep 1

echo -e "\n-----------------from hardlink to symlink-----------------"
rm -rf a/b/c
ln -sr a/file a/b/c
../bkit.sh .
sleep 1

echo -e "\n-----------------from symlink to a file-----------------"
rm -rf a/b/c
mkdir -pv a/b/c/
echo $RANDOM > a/b/c/d
../bkit.sh .
sleep 1

echo -e "\n-----------------from file to hardlink-----------------"
rm -rf a/b/c
ln a/file a/b/c
../bkit.sh .
sleep 1

echo -e "\n-----------------from hardlink to directory-----------------"
rm -rf a/b/c
mkdir -pv a/b/c/
echo $RANDOM > a/b/c/d
../bkit.sh .
sleep 1

echo -e "\n-----------------from directory to hardlink + file-----------------"
rm -rf a/b/c
ln a/file a/b/c
echo $RANDOM > a/b/file
../bkit.sh .
sleep 1

echo -e "\n-----------------from file to symblink-----------------"
rm -rf a/b/c
ln -sfr a/file a/b/file
../bkit.sh .
sleep 1

