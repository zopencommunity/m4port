#!/bin/sh
#
# Run tests from the 'examples' directory
#
whence m4 >/dev/null
if [ $? -gt 0 ]; then
	echo "Need to add m4 directory to your PATH. Location after build is in the 'src' directory of m4 directory tree" >&2 
	exit 16
fi

if [ "${M4_ROOT}" = '' ] || [ "${M4_VRM}" = '' ]; then
	echo "Need to source setenv.sh before running this script" >&2
	exit 16
fi

#
# Create an m4 test that consists of the example function and some usage of it
#
EXAMPLES="${M4_ROOT}/${M4_VRM}/examples"
M4_VRM="m4-1.4.19"

EXPECTED_OUTPUT='HELLO world!'
m4test=`cat ${EXAMPLES}/capitalize.m4`
m4drive="upcase(hello) downcase(World!)"

output=`echo "${m4test}
${m4drive}" | m4`

if [ "${output}" = "${EXPECTED_OUTPUT}" ]; then
	echo "Success"
	exit 0
else
    	echo "m4 output is not correct." >&2
	echo "Expected:" >&2
	echo "${EXPECTED_OUTPUT}" >&2
	echo "Actual:" >&2
	echo "${output}" >&2
	exit 16
fi
