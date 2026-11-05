# shellcheck shell=bash
#
# archive.sh - the archive of the site (src/net_practice*.tgz): which one it is, what it holds, and where each of its files goes.
# Sourced by run.sh (it only defines functions). Needs log.sh. Variables it sets:
#   ARCHIVE   the path of the archive, empty when there is none
#   LISTING   the names of its members, one per line (net_practice/js/sim.js)
#   REL       the place of one member in the site (js/sim.js), set by archive_path

# archive_find   sets ARCHIVE from src/. One archive is expected, and two are an error.
archive_find()
{
	local found

	ARCHIVE=
	for found in src/net_practice*.tgz; do
		[ -f "$found" ] || continue
		[ -z "$ARCHIVE" ] || log_fail "more than one archive in src/ ($ARCHIVE and $found): keep one"
		ARCHIVE=$found
	done
}

# archive_list   sets LISTING.
archive_list()
{
	LISTING=$(tar -tzf "$ARCHIVE") || log_fail "cannot read $ARCHIVE"
}

# archive_path MEMBER   sets REL to the place of a member in the site: net_practice/js/sim.js goes to js/sim.js.
# Returns 1 for what is not a file of the site: a folder, and the run.sh of the archive (this one replaces it).
# A name that would leave this folder, or reach src/ (the modules) or .git, stops everything.
archive_path()
{
	REL=${1#./}
	case $REL in */) return 1 ;; */*) REL=${REL#*/} ;; *) return 1 ;; esac
	[ "$REL" != run.sh ] || return 1
	case /$REL/ in
		*/../* | /src/* | /.git/*) log_fail "$ARCHIVE holds a file that cannot be extracted here ($1): it leaves the folder, or is in src/ or .git" ;;
	esac
}
