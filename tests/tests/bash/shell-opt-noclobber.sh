## ST-NAME: 

set -o noclobber


tmpdir="/tmp/shelllab/test-$0.$$"
mkdir -p "$tmpdir"

echo "toto" > "$tmpdir/plop"
echo "toto2" > "$tmpdir/plop"
cat "$tmpdir/plop"

echo "toto" > "$tmpdir/plop2"
echo "toto2" >| "$tmpdir/plop2"
cat "$tmpdir/plop2"
