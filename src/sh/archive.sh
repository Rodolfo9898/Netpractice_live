# shellcheck shell=bash
#
# archive.sh - the archive of the site (src/net_practice*.tgz): which one it is, what it holds, where each of its files goes, and a
# copy of it unpacked to read from. Sourced by run.sh (it only defines functions). Needs log.sh. Variables it sets:
#   ARCHIVE   the path of the archive, empty when there is none
#   LISTING   the names of its members, one per line (net_practice/js/sim.js); empty until archive_list has read and checked them
#   REL       the place of one member in the site (js/sim.js), set by archive_path and archive_dir
#   WORK      the temporary folder the archive is unpacked in, empty when there is none

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

# archive_list   reads the names of the archive into LISTING. A name that would leave this folder, or reach src/ (the modules) or
# .git, stops everything before anything is extracted or removed: LISTING only has names that were checked.
archive_list()
{
	local names member

	names=$(tar -tzf "$ARCHIVE") || log_fail "cannot read $ARCHIVE"
	LISTING=
	while IFS= read -r member; do
		archive_path "$member" || :
	done <<< "$names"
	LISTING=$names
}

# archive_path MEMBER   sets REL to the place of a file of the archive in the site: net_practice/js/sim.js goes to js/sim.js.
# Returns 1 for what is not a file of the site: a folder, the top folder, a file outside of it, and the run.sh of the archive (this
# one replaces it). A name that is not allowed stops everything.
archive_path()
{
	REL=${1#./}
	case $REL in */*) REL=${REL#*/} ;; *) return 1 ;; esac
	case /$REL/ in
		*/../* | /src/* | /.git/*) log_fail "$ARCHIVE holds a file that cannot be extracted here ($1): it leaves the folder, or is in src/ or .git" ;;
	esac
	case $REL in '' | */) return 1 ;; esac
	[ "$REL" != run.sh ] || return 1
}

# archive_dir MEMBER   sets REL to the place of a folder of the archive in the site: net_practice/js/ goes to js. Returns 1 for the rest.
archive_dir()
{
	archive_path "$1" && return 1
	case ${1#./} in */) ;; *) return 1 ;; esac
	REL=${1#./}
	REL=${REL#*/}
	REL=${REL%/}
	[ -n "$REL" ]
}

# archive_unpack   unpacks the archive in a temporary folder, WORK, and makes it readable whatever the modes it holds. When it cannot,
# it says why, leaves nothing behind and returns 1.
archive_unpack()
{
	WORK=$(mktemp -d "${TMPDIR:-/tmp}/netpractice.XXXXXX") || { WORK=; log_warn "cannot make a temporary folder"; return 1; }
	if ! tar -xzf "$ARCHIVE" -C "$WORK"; then
		log_warn "cannot extract $ARCHIVE"
		archive_forget
		return 1
	fi
	chmod -R u+rwX "$WORK"
}

# archive_forget   removes WORK (run.sh does it when it ends, whatever way it ends).
archive_forget()
{
	[ -z "${WORK:-}" ] || rm -rf "$WORK"
	WORK=
}
