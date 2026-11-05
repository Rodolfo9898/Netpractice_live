#!/usr/bin/env bash

# NetPractice, the training interface of the intranet (net_practice.1.9.tgz).
#
# This is the main. The work is in the modules of src/sh/, which only define functions (they are loaded here, in this order):
#
#   src/sh/log.sh      the messages, and the errors that stop everything
#   src/sh/archive.sh  finds the archive in src/ and says where each of its files goes
#   src/sh/site.sh     checks that the site is all here, and extracts from the archive what is missing
#   src/sh/server.sh   finds a free port, starts the web server and opens the browser
#
# git keeps this script, the modules and the archive (src/net_practice.1.9.tgz), and none of the site: index.html, levelN.html,
# js/, css/, img/ and License. They are extracted from the archive into this folder when any of them is missing, then served. A
# file that is already here is never overwritten (delete it to get the archive's version back). The run.sh of the archive is not
# extracted: this one replaces it.
#
#   ./run.sh              extract what is missing, start the server and open the browser
#   ./run.sh --extract    only extract what is missing: no server, no browser (for the tests of a project that uses this one)

[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"	# started with "sh run.sh": this file needs bash

ROOT=$(cd -- "$(dirname -- "$0")" && pwd) || exit 1
cd -- "$ROOT" || exit 1					# the server serves the folder it is started in: this one

for module in log archive site server; do
	[ -f "$ROOT/src/sh/$module.sh" ] || { echo "Netpractice: src/sh/$module.sh is missing" >&2; exit 1; }
	. "$ROOT/src/sh/$module.sh"
done

main()
{
	case ${1:-} in
		'' | --extract) ;;
		*) log_fail "usage: ./run.sh [--extract]" ;;
	esac
	site_ensure
	[ "${1:-}" != --extract ] || return 0
	server_run
}

main "$@"
