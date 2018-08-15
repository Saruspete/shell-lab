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

OPT_VERBOSE=0
TEMP_BASE="/tmp/shelllab/run.$$"

# Declare the interpreter
INTERP_BASE="$MYPATH/interpreters"
INTERP_LIST=""

# Declare the tests to run
TESTS_BASE="$MYPATH/tests"
TESTS_LIST=""
#TESTS_LIST="$MYPATH/tests/posix/allargs.sh $MYPATH/tests/posix/arg0.sh $MYPATH/tests/ksh/arg0.sh"
#INTERP_LIST="/bin/bash /bin/ksh"

#
# Helpers
#

log_info() { echo "$@"; }
log_error() { echo >&2 "$@"; }
log_warning() { echo >&2 "$@"; }

die() {
	log_error "$@"
	exit 1
}

temp_create() {
	_dir="$TEMP_BASE/$1"
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

			
			if [ $_reschk -ne 0 ] && [ $OPT_VERBOSE -gt 0 ]; then
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



# Parse options
OPT_ERR=0
while [ -n "${1:-}" ]; do
	opt="$1"
	shift
	val="${1:-}"

	# Special case for --opt=val
	case "$opt" in
		--*=*)
			val="${opt#*=}"
			opt="${opt%%=*}"
			;;
	esac

	# Parsing
	case "$opt" in
		-i|--interp)
			# Defined interpreter
			if [ -s "$INTERP_BASE/$val" ]; then
				INTERP_LIST="$INTERP_LIST $INTERP_BASE/$val"
				shift
			# All available interpreter
			elif [ "$val" = "ALL" ]; then
				INTERP_LIST=""
				for i in $INTERP_BASE/*; do
					[ -x "$i" ] && {
						INTERP_LIST="$INTERP_LIST $i"
					}
				done
				shift

			# Invalid value
			else
				log_error "Invalid interpreter: '$val'"
				OPT_ERR="$(($OPT_ERR + 1))"
			fi
			;;

		-t|--test)
			if [ -s "$TESTS_BASE/$val" ]; then
				TESTS_LIST="$TESTS_LIST $TESTS_BASE/$val"
				shift
			elif [ "$val" = "ALL" ]; then
				TESTS_LIST=""
				for i in $TESTS_BASE/*/*.sh; do
					# Add the test if executable
					[ -x "$i" ] && {
						if [ -s "${i%.sh}.check" ]; then
							TESTS_LIST="$TESTS_LIST $i"
						else
							log_warning "Test '${i#$TESTS_BASE/}' does not have .check script"
						fi
					}
				done
				shift
			else
				log_error "Invalid tests: '$val'"
				OPT_ERR="$(($OPT_ERR +1))"
			fi
			;;

		-v|--verbose)
			OPT_VERBOSE=$(($OPT_VERBOSE +1))
			;;

		*)
			log_error "Invalid option '$opt'"
			OPT_ERR="$(($OPT_ERR +1))"
			;;
	esac
done

# Stop if we had parsing error
[ $OPT_ERR -ne 0 ] && {
	log_error "Errors during parsing... stop"
	exit 1
}



test_runall
