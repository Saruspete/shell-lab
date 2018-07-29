#!/bin/bash



echo 'Using $@'
for a in $@; do echo "- $a"; done

echo
echo 'Using $*'
for a in $*; do echo "- $a"; done

echo
echo 'Using "$@"'
for a in "$@"; do echo "- $a"; done


echo
echo 'Using "$*" + IFS=:'
IFS=:
for a in "$*"; do echo "- $a"; done



