## SLT-Name: AllArgs
## SLT-Desc: Behaviour of "$@" and "$*"
## SLT-Args: "hello" "world" "this is a long sequence" "finally..."

echo 'Using $@'
for a in $@; do echo "- $a"; done

echo
echo 'Using $*'
for a in $*; do echo "- $a"; done

echo
echo 'Using "$@"'
for a in "$@"; do echo "- $a"; done

echo
echo 'Using "$*"'
for a in "$*"; do echo "- $a"; done

echo
echo 'Using "$*" + IFS=:'
IFS=:
for a in "$*"; do echo "- $a"; done

