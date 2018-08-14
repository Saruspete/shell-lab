## SLT-Name: Arg0
## SLT-Desc: What is the value of $0 in global or in function

g() { echo "$0"; }
h() ( echo "$0"; )


echo "$0 / $(g) / $(h)"
