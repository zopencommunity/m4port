#!/bin/sh
#
# Manage patches
# To create or refresh patch:
#   -perform a git diff of the affected files and redirect to a patch file
#
#set -x
if [ $# -ne 0 ]; then
	echo "Syntax: managepatches" >&2
	echo "  refreshes patch files" >&2
	exit 8
fi

# mydir="$(dirname $0)"

if [ "${M4_ROOT}" = '' ]; then
	echo "Need to set M4_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${M4_VRM}" = '' ]; then
	echo "Need to set M4_VRM - source setenv.sh" >&2
        exit 16
fi

CODE_ROOT="${M4_ROOT}/${M4_VRM}"
PATCH_ROOT="${M4_ROOT}/patches"
patches=`cd ${PATCH_ROOT} && find . -name "*.patch"`

for patch in $patches; do
	rp="${patch%*.patch*}"
	o="${CODE_ROOT}/${rp}.orig"
	f="${CODE_ROOT}/${rp}"
	p="${PATCH_ROOT}/${patch}"

	if [ -f "${o}" ]; then
		# Original file exists. Regenerate patch, then replace file with original version 
		diff -C 2 -f "${o}" "${f}" | tail +3 >"${p}"
		cp "${o}" "${f}"
	else
		# Original file does not exist yet. Create original file
		cp "${f}" "${o}"
	fi

	patchsize=`wc -c "${p}" | awk '{ print $1 }'` 
	if [ $patchsize -eq 0 ]; then
		echo "Warning: patch file ${f} is empty - nothing to be done" >&2 
	else 
		out=`patch -c "${f}" <"${p}" 2>&1`
		if [ $? -gt 0 ]; then
			echo "Patch of perl tree failed (${f})." >&2
			echo "${out}" >&2
			exit 16
		fi
	fi
done

exit 0	
