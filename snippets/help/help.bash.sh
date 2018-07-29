#!/bin/bash

set -o nounset

typeset MYSELF="$(readlink -f $0)"
typeset MYPATH="${MYSELF%/*}"

die () {
	echo >&2 "$@"
	exit 1
}

# Help:
show_help () {
	cat <<-EOT
	Usage: $0 <required_params> [optionnal_params]
	This is a sample script to show usage of dynamic help
	EOT

	# Get the begin / end lines
	typeset help_begin="$(grep -n '[\t ]*## [H]ELP-BEGIN' "$MYSELF"|head -n1)"
	typeset help_end="$(grep -n '[\t ]*## [H]ELP-END' "$MYSELF"|tail -n1)"
	# Remove the grep output to only keep the line number
	help_begin="${help_begin%%:*}"
	help_end="${help_end%%:*}"

	[[ -z "$help_begin" ]] && die "Cannot find help headers. Please contact script maintainer"

	# This text should be the longest we'll find
	typeset help_block="$(head -n $(($help_end-1)) "$MYSELF" | tail -n $(($help_end-$help_begin -1)) )"

	#
	# Look for all lines starting by $cmt (## by default). Concat their value if multiple found.
	# Look for a ) to match a case value. Then output case and text and reset text
	# You can change the comment pattern to look for by changing the value of "cmt"
	# You can change the space size between options and text
	echo "$help_block" | awk -v pad=30 -v cmt="##" -v cols="${COLUMNS:-$(tput cols)}" '
	BEGIN { rgx="\\s*"cmt"\\s*(.+)"; tsz=int(cols)-int(pad)-4;}
	{
		# Look for the comment delimiter
		if (match($0,rgx,a) ) {
			txt=(txt) a[1]
		}
		# Look for a case option, not begining with a # (and indent)
		else if ( match($0, /^\s*([^#\s]+[^)]+)\)/, a) ) {
			printf "  %-"pad"."pad"s %."tsz"s\n", a[1], txt
			txtlen=length(txt)
			if (txtlen > tsz) {
				for(i=tsz; i<=txtlen; i+=tsz) {
					printf "  %"pad"s %."tsz"s\n", "", substr(txt, i+1)
				}
			}
			txt=""
		}
	}'
}


## HELP-BEGIN
case $1 in
	## Redirect the output somewhere else
	-o|--output)
		;;

	## Show this help
	## and also this line...
	# but not that one (it's not the separator ##) doh
	-h|--help)
		show_help
		;;

	## This is gonna be a very long and explicit line that will
	## certainly overflow the size of your temrinal...
	-v|--version)

esac
## HELP-END

