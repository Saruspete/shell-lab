#!/bin/sh

set -o nounset
set -o noclobber

[ -z "$SLT_RUNDIR" ] && {
	echo "This script must be called through runtest.sh"
	exit 99
}

case ${1:-} in
	# Noting to do here
	pre)
		;;

	# Check stdout output
	post)
		[ -s "$SLT_RUNDIR/run.out" ] || exit 1
		
		# This is the expected output
		cat >| $SLT_RUNDIR/run.out.check  <<-'EOT'
		Using $@
		- hello
		- world
		- this
		- is
		- a
		- long
		- sequence
		- finally...

		Using $*
		- hello
		- world
		- this
		- is
		- a
		- long
		- sequence
		- finally...

		Using "$@"
		- hello
		- world
		- this is a long sequence
		- finally...

		Using "$*"
		- hello world this is a long sequence finally...

		Using "$*" + IFS=:
		- hello:world:this is a long sequence:finally...
		EOT

		# No error to be expected
		>| "$SLT_RUNDIR/run.err.check"

		diff --brief "$SLT_RUNDIR/run.out"{,.check} >/dev/null || exit 1
		diff --brief "$SLT_RUNDIR/run.err"{,.check} >/dev/null || exit 1

		exit 0
		;;

	# Display diff
	diff)
		[ -z "$SLT_DIFF" ] && exit 1
		$SLT_DIFF "$SLT_RUNDIR/run.out" "$SLT_RUNDIR/run.out.check"
		;;

	# Unknown command
	*)
		echo >&2 "Unknown command '$1'"
		exit 99
		;;
esac
