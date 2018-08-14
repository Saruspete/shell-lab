#!/bin/sh

set -o nounset
set -o noclobber

MYSELF="$(readlink -f $0)"
export MYPATH="${MYSELF%/*}"

# Reset to more secure values
export LC_ALL=C
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:${PATH:-}"

# And some helpful functions
#export SLT_DIFF="diff --side-by-side --suppress-common-lines"
export SLT_DIFF="diff"


TEMPBASE="/tmp/shelllab/run.$$"

# Declare the interpreter
INTERP_BASE="$MYPATH/interpreters"
INTERP_LIST=""

# Declare the tests to run
TESTS_LIST="$MYPATH/tests/posix/allargs.sh $MYPATH/tests/posix/arg0.sh $MYPATH/tests/ksh/arg0.sh"
INTERP_LIST="/bin/bash /bin/ksh"





#
# Helpers
#

log_info() {
	echo "$@"
}

log_error() {
	echo >&2 "$@"
}

die() {
	log_error "$@"
	exit 1
}

temp_create() {
	_dir="$TEMPBASE/$1"
	mkdir -p "$_dir"
	echo "$_dir"
}



#
# Check functions
#
check_test() {

	script="$1"
	step="$2"

	# Script that will do the check
	check="${script%.sh}.check"
	[ -s "$check" ] || {
		log_error "No check file $check found for current test"
		return 1
	}

	# Exec in a subshell for security
	(
		# Source the file
		. "$check"
		# Call the stub
		slt_check_$step
	)
}



#
# Test functions
#
# Run a test
test_runall() (
	
	for testscript in $TESTS_LIST; do

		log_info "==== Running test of '${testscript#$MYPATH/tests/}'"

		# Do the check with every interpreter
		for interp in $INTERP_LIST; do

			log_info -n "== '${interp##*/}' => "

			_testscriptname="${testscript##*/}"
			_family="${testscript%/*}"
			_family="${_family##*/}"
			export SLT_RUNDIR="$(temp_create "$_family.$_testscriptname.${interp##*/}")"

			# Pre-check
			check_test "$testscript" "pre"

			# Reset positional parameters
			set - ''
			# This eval is to handle the quoted arguments
			eval "set - $(test_getvar "$testscript" "Args")"

			# Run the script
			echo "$testscript $@" > "$SLT_RUNDIR/run.cmd"
			"$interp" "$testscript" "$@" 1>"$SLT_RUNDIR/run.out" 2>"$SLT_RUNDIR/run.err"
			_resrun=$?

			# Post-check
			check_test "$testscript" "post" "$_resrun"
			_reschk=$?

			log_info " $_reschk (Run: $_resrun)"

			
			if [ $_reschk -ne 0 ]; then
				log_info "== Diff:"
				check_test "$testscript" "diff"
			fi

		done
		
		log_info
	done
)

test_getvars() {
	_testpath="$1"
	awk 'match($0,"^## SLT-(.+?):(.*)",a) {
		gsub("([\"])","\\\1", a[2]);
		print a[1]"=\""a[2]"\"";
	}' "$_testpath"
}

test_getvar() {
	_testpath="$1"
	_testvar="$2"
	awk 'match($0,"^## SLT-'${_testvar}':(.*)",a) { print a[1]; }' "$_testpath"
}



[ -z "$INTERP_LIST" ] && die "You must provide at least one interpreter to check"


test_runall
