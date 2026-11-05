#!/usr/bin/env bash

# NetPractice, the training interface of the intranet (net_practice.1.9.tgz).
#
# This is the main. The work is in the modules of src/sh/, which only define functions (they are loaded here, in this order):
#
#   src/sh/log.sh      the messages, and the errors that stop everything
#   src/sh/archive.sh  finds the archive in src/, checks its names and unpacks it to read from
#   src/sh/site.sh     checks that the site is all here, and extracts from the archive what is missing
#   src/sh/destroy.sh  removes the site again, so that only what git keeps is left
#   src/sh/server.sh   finds a free port, starts the web server and opens the browser
#
# git keeps this script, the modules and the archive (src/net_practice.1.9.tgz), and none of the site: index.html, levelN.html,
# js/, css/, img/ and License. They are extracted from the archive into this folder when any of them is missing, then served, and
# removed when the server stops. A file that is already here is never overwritten, and one that was changed is never removed. The
# run.sh of the archive is not extracted: this one replaces it.
#
#   ./run.sh              extract what is missing, start the server and open the browser; remove the site when the server stops
#   ./run.sh --extract    only extract what is missing: no server, no browser, nothing removed (for the tests of a project that uses this one)
#   ./run.sh --destroy    only remove the site (what a run that was killed, or --extract, left)

[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"	# started with "sh run.sh": this file needs bash

ROOT=$(cd -- "$(dirname -- "$0")" && pwd) || exit 1
cd -- "$ROOT" || exit 1					# the server serves the folder it is started in: this one

for module in log archive site destroy server; do
	[ -f "$ROOT/src/sh/$module.sh" ] || { echo "Netpractice: src/sh/$module.sh is missing" >&2; exit 1; }
	. "$ROOT/src/sh/$module.sh"
done

main()
{
	local mode=serve

	case ${1:-} in
		'') ;;
		--extract) mode=extract ;;
		--destroy) mode=destroy ;;
		*) log_fail "usage: ./run.sh [--extract | --destroy]" ;;
	esac
	trap archive_forget EXIT				# the temporary folder never outlives the script
	case $mode in
		extract)
			site_ensure
			;;
		destroy)
			archive_find
			[ -n "$ARCHIVE" ] || log_fail "no archive in src/ (src/net_practice*.tgz) to tell what the site is made of"
			archive_list
			destroy_site
			[ "$REMOVED" -gt 0 ] || [ "${#KEPT[@]}" -gt 0 ] || log_say "no file of the site is here."
			;;
		serve)
			trap 'archive_forget; destroy_site' EXIT	# the site goes when the server stops, whatever way it stops (Ctrl-C included)
			site_ensure
			server_run
			;;
	esac
}

main "$@"
