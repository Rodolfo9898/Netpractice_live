# shellcheck shell=bash
#
# log.sh - the messages of run.sh. Sourced by run.sh (it only defines functions), like the other modules of src/sh/.

# log_say TEXT...    a line for the person who started the script
log_say()
{
	echo "Netpractice: $*"
}

# log_warn TEXT...   a problem, on the error output; the script goes on (or not) as its caller decides
log_warn()
{
	echo "Netpractice: $*" >&2
}

# log_fail TEXT...   the reason on the error output, then the whole script ends with status 1 (nothing is started after it)
log_fail()
{
	log_warn "$*"
	exit 1
}
