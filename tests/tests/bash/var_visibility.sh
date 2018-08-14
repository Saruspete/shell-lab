
vgr="global"
vgro="global"
typeset vgt="global"
typeset vgto="global"

f () {
	echo "Inside f:"
	echo " - Global implicit: $vgr"
	echo " - Global typeset:  $vgt"
	echo

	vlr="from f"
	typeset vlt="from f"

	vgro="from f"
	typeset vgto="from f"
}

function g {
	echo "Inside g:"
	echo " - Global implicit: $vgr"
	echo " - Global typeset:  $vgt"
	echo

	vlr="from g"
	typeset vlt="from g"

	vgro="from g"
	typeset vgto="from g"
}

f

echo "After calling f"
echo " - Global implicit: $vgr"
echo " - Global typeset:  $vgt"
echo " - Global implicit override: $vgro"
echo " - Global typeset  override: $vgro"
echo " - local f implicit: $vlr"
echo " - local f typeset: $vlt"
echo

g

echo "After calling g"
echo " - Global implicit: $vgr"
echo " - Global typeset:  $vgt"
echo " - Global implicit override: $vgro"
echo " - Global typeset  override: $vgro"
echo " - local f implicit: $vlr"
echo " - local f typeset: $vlt"

