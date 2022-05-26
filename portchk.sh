#!/bin/sh
#
# m4 check should have 4 (or 3) failures (3 if a git build)
# Determine number of failures by looking at testcases on line _after_ 'Failed checks were:' line
#
dir="$1"
pfx="$2"
chk="$1/$2_check.log"

set -x
start_line=$(cat "${chk}" | egrep -n '^Failed checks were:' | awk -F':' '{ print $1 }')
if [ $? -eq 0 ]; then
	failures=$(cat "${chk}" | tail +${start_line} | head -2 | tail -1 | wc -w)
	if [ ${failures} -gt 4 ]; then
		exit 1
	else
		exit 0
	fi
fi
exit 1
