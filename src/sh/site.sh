# shellcheck shell=bash
#
# site.sh - the site itself: is it all here, and if not, get what is missing from the archive.
# Sourced by run.sh (it only defines functions). Needs log.sh and archive.sh. Variables it sets:
#   MISSING   the files of the site that are not here (an array)
#   TOTAL     how many files the site has
#   WORK      the temporary folder the archive is unpacked in

# site_look   sets MISSING and TOTAL, from the listing of the archive.
site_look()
{
	local member

	MISSING=()
	TOTAL=0
	while IFS= read -r member; do
		archive_path "$member" || continue
		TOTAL=$((TOTAL + 1))
		[ -e "$REL" ] || [ -L "$REL" ] || MISSING+=("$REL")
	done <<< "$LISTING"
}

# site_extract   unpacks the archive in a temporary folder (removed whatever happens) and copies from it the files that are
# not here. A file that is already here is left as it is.
site_extract()
{
	local member from

	WORK=$(mktemp -d "${TMPDIR:-/tmp}/netpractice.XXXXXX") || log_fail "cannot make a temporary folder"
	trap 'rm -rf "$WORK"' EXIT
	tar -xzf "$ARCHIVE" -C "$WORK" || log_fail "cannot extract $ARCHIVE"
	chmod -R u+rwX "$WORK"		# (whatever the modes in the archive, it can be read, and removed)
	while IFS= read -r member; do
		archive_path "$member" || continue
		if [ -e "$REL" ] || [ -L "$REL" ]; then
			continue
		fi
		from=$WORK/${member#./}
		if [ ! -f "$from" ] || [ -L "$from" ]; then
			log_fail "$member is not a plain file in $ARCHIVE"
		fi
		mkdir -p -- "$(dirname -- "$REL")" && cp -p -- "$from" "$REL" || log_fail "cannot write $REL"
	done <<< "$LISTING"
	rm -rf "$WORK"
}

# site_ensure   the whole of it: returns when the site is all here (extracting what was missing), stops the script when it cannot be.
# Without an archive there is nothing to compare with: the site is taken as it is if it has its start page.
site_ensure()
{
	archive_find
	if [ -z "$ARCHIVE" ]; then
		[ -f index.html ] || log_fail "the site is not here and there is no archive to extract it from (src/net_practice*.tgz)"
		return 0
	fi
	archive_list
	site_look
	[ "$TOTAL" -gt 0 ] || log_fail "there is no site in $ARCHIVE"
	[ "${#MISSING[@]}" -gt 0 ] || return 0
	if [ "${#MISSING[@]}" -eq "$TOTAL" ]; then
		log_say "extracting the site from $ARCHIVE."
	else
		log_say "${#MISSING[@]} of the $TOTAL files of the site are missing, restoring them from $ARCHIVE."
	fi
	site_extract
	site_look
	[ "${#MISSING[@]}" -eq 0 ] || log_fail "still missing after extracting $ARCHIVE: ${MISSING[*]}"
}
