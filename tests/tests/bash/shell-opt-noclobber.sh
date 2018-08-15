## ST-NAME: 

set -o noclobber

echo "toto" > "$SLT_RUNDIR/plop.$$"
echo "toto2" > "$SLT_RUNDIR/plop.$$"
cat "$SLT_RUNDIR/plop.$$"

echo "toto" > "$SLT_RUNDIR/plop2.$$"
echo "toto2" >| "$SLT_RUNDIR/plop2.$$"
cat "$SLT_RUNDIR/plop2.$$"
