## SLT-Name: Arg0
## SLT-Desc: What is the value of $0 in global or in function

a() { echo "$0"; }
b() ( echo "$0"; )
function c { echo "$0"; }


echo "$0 / $(a) / $(b) / $(c)"
