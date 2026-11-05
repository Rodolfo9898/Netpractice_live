#!/usr/bin/env bash

# NetPractice, the training interface of the intranet (net_practice.1.9.tgz).
#
# git keeps this script and the archive in src/, and none of the site: index.html, levelN.html, js/, css/, img/ and License. They are
# extracted from the archive into this folder when any of them is missing, then served. A file that is already here is never
# overwritten (delete it to get the archive's version back). The run.sh of the archive, which is only the starter at the bottom of
# this file, is not extracted: this one stays.
#
#   ./run.sh              extract what is missing, start the server and open the browser
#   ./run.sh --extract    only extract what is missing: no server, no browser (for the tests of a project that uses this one)

[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"	# started with "sh run.sh": this file needs bash

cd -- "$(dirname -- "$0")" || exit 1			# the server serves the folder it is started in: this one

fail()
{
	echo "Netpractice: $*" >&2
	exit 1
}

# net_practice/js/sim.js, a name of the archive, becomes js/sim.js in $rel. A folder is not a file of the site, nor is the run.sh of the
# archive: they make this return 1. A name that would leave this folder stops everything.
relative()
{
	rel=${1#./}
	case $rel in */) return 1 ;; */*) rel=${rel#*/} ;; *) return 1 ;; esac
	[ "$rel" != run.sh ] || return 1
	case /$rel/ in */../*) fail "$archive has a name that leaves this folder: $1" ;; esac
}

# Fills $missing with the files of the site that are not here, and $total with the number of files the site has.
look()
{
	local member

	missing=()
	total=0
	while IFS= read -r member; do
		relative "$member" || continue
		total=$((total + 1))
		[ -e "$rel" ] || [ -L "$rel" ] || missing+=("$rel")
	done <<< "$listing"
}

# Extracts the archive into a temporary folder and copies from it the files that are not here (the others are left as they are).
extract()
{
	local member from

	tmp=$(mktemp -d "${TMPDIR:-/tmp}/netpractice.XXXXXX") || fail "cannot make a temporary folder"
	trap 'rm -rf "$tmp"' EXIT
	tar -xzf "$archive" -C "$tmp" || fail "cannot extract $archive"
	chmod -R u+rwX "$tmp"		# (whatever the modes in the archive, it can be read, and removed)
	while IFS= read -r member; do
		relative "$member" || continue
		if [ -e "$rel" ] || [ -L "$rel" ]; then
			continue
		fi
		from=$tmp/${member#./}
		if [ ! -f "$from" ] || [ -L "$from" ]; then
			fail "$member is not a plain file in $archive"
		fi
		mkdir -p -- "$(dirname -- "$rel")" && cp -p -- "$from" "$rel" || fail "cannot write $rel"
	done <<< "$listing"
	rm -rf "$tmp"
}

case ${1:-} in
	'' | --extract) ;;
	*) fail "usage: ./run.sh [--extract]" ;;
esac

archive=
for found in src/net_practice*.tgz; do
	[ -f "$found" ] || continue
	[ -z "$archive" ] || fail "more than one archive in src/ ($archive and $found): keep one"
	archive=$found
done

if [ -n "$archive" ]; then
	listing=$(tar -tzf "$archive") || fail "cannot read $archive"
	look
	[ "$total" -gt 0 ] || fail "there is no site in $archive"
	if [ "${#missing[@]}" -gt 0 ]; then
		if [ "${#missing[@]}" -eq "$total" ]; then
			echo "Netpractice: extracting the site from $archive."
		else
			echo "Netpractice: ${#missing[@]} of the $total files of the site are missing, restoring them from $archive."
		fi
		extract
		look
		[ "${#missing[@]}" -eq 0 ] || fail "still missing after extracting $archive: ${missing[*]}"
	fi
elif [ ! -f index.html ]; then
	fail "the site is not here and there is no archive to extract it from (src/net_practice*.tgz)"
fi

[ "${1:-}" != --extract ] || exit 0

myport='49242'

if command -v ss >/dev/null 2>&1; then
	for port in $(seq 49152 65535); do
		if ! ss -lnt | grep -q ":$port "; then
			myport=$port
			break
		fi
	done
else
    echo "ss not available, using port 49242."
fi


if command -v xdg-open >/dev/null 2>&1; then
	echo "Netpractice server is starting, web browser will open."
	( sleep 2 ; xdg-open "http://localhost:$myport" >/dev/null 2>&1 || true ) &
else
	if command -v open >/dev/null 2>&1; then
		echo "Netpractice server is starting, web browser will open."
		( sleep 2 ; open "http://localhost:$myport" >/dev/null 2>&1 || true ) &
	else
		echo "Netpractice server is starting. Open your web browser with URL: http://localhost:$myport"
	fi
fi

echo "Type Ctrl-C to shutdown the server."

python3 -m http.server $myport
