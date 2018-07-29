#!/bin/bash


function f {
	echo "In function f: $0 / $FUNCNAME"
}

g () {
	echo "In g(): $0 / $FUNCNAME"
}

echo "Global: $0 / $FUNCNAME"
f
g
