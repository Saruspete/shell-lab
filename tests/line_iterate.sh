#!/bin/bash

typeset -A users

echo "===== Pure Bash"
awk -F: '$3>100{print $1,$5}' /etc/passwd | while read login gecos; do
    users[$login]="$gecos"
done

for login in ${!users[@]}; do
	echo "$login = ${users[$login]}"
done

read t


#### Solution 1
echo "===== Solution 1 : Bashism"
while read login gecos; do
    users[$login]="$gecos"
done < <(awk -F: '$3>100{print $1,$5}' /etc/passwd)

for login in ${!users[@]}; do
	echo "$login = ${users[$login]}"
done

read t

#### Solution 2

echo "===== Solution 2 : set hack"
set +m
shopt -s lastpipe

awk -F: '$3>100{print $1,$5}' /etc/passwd | while read login gecos; do
    users[$login]="$gecos"
done

for login in ${!users[@]}; do
	echo "$login = ${users[$login]}"
done
