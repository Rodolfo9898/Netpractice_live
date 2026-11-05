# shellcheck shell=bash
#
# log.sh - the messages of run.sh. Sourced by run.sh (it only defines functions), like the other modules of src/sh/.

# log_say TEXT...    a line for the person who started the script
log_say()
{
	echo "Netpractice: $*"
}

# log_fail TEXT...   the reason on the error output, then the whole script ends with status 1 (nothing is started after it)
log_fail()
{
	echo "Netpractice: $*" >&2
	exit 1
}
