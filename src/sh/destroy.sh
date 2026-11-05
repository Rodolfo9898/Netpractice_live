# shellcheck shell=bash
#
# destroy.sh - the opposite of site.sh: takes the site out of this folder, so that only what git keeps is left (run.sh, src/, the
# README). Sourced by run.sh (it only defines functions), which does it when the server stops. Needs log.sh and archive.sh, and the
# archive read (archive_find, archive_list). Variables it sets:
#   REMOVED   how many files it removed
#   KEPT      the files of the site it did not remove (an array)

# destroy_site   removes every file of the site that is here and is still the archive's own (compared byte for byte), then the folders
# that leaves empty (the .DS_Store files the Finder drops in them go too). It keeps, and names, a file that was changed or that cannot
# be removed, and everything the archive does not have: it never deletes what somebody wrote. Without a read archive nothing says
# what is the site's, and nothing is removed.
destroy_site()
{
	local member dir dirs folders

	REMOVED=0
	KEPT=()
	[ -n "${LISTING:-}" ] || return 0
	trap '' INT TERM HUP						# (cleaning is not stopped half way)
	archive_unpack || { log_warn "the site is left here: it cannot be compared with the archive"; return 0; }
	dirs=()
	while IFS= read -r member; do
		if archive_dir "$member"; then
			dirs+=("$REL")
		elif archive_path "$member"; then
			[ -e "$REL" ] || [ -L "$REL" ] || continue
			if [ -f "$REL" ] && [ ! -L "$REL" ] && cmp -s -- "$WORK/${member#./}" "$REL" && rm -f -- "$REL"; then
				REMOVED=$((REMOVED + 1))
			else
				KEPT+=("$REL")
			fi
		fi
	done <<< "$LISTING"
	archive_forget
	folders=$(printf '%s\n' "${dirs[@]}" | sort -r)			# (the deepest first)
	while IFS= read -r dir; do
		[ -n "$dir" ] && [ -d "$dir" ] && [ ! -L "$dir" ] || continue
		rm -f -- "$dir/.DS_Store"
		rmdir -- "$dir" 2>/dev/null || :
	done <<< "$folders"
	[ "$REMOVED" -eq 0 ] || log_say "removed the site ($REMOVED files)."
	[ "${#KEPT[@]}" -eq 0 ] || log_say "kept ${#KEPT[@]} file(s) of the site that differ from the archive or cannot be removed: ${KEPT[*]}"
	return 0
}
