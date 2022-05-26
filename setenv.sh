#!/bin/sh
#
# Set up environment variables for general build tool to operate
#
if ! [ -f ./setenv.sh ]; then
	echo "Need to source from the setenv.sh directory" >&2
	return 0
fi

export PORT_ROOT="${PWD}"
export PORT_TYPE="TARBALL"

PORT_TARBALL_DIR=m4-1.4.19
export PORT_TARBALL_URL="https://ftp.gnu.org/gnu/m4/${PORT_TARBALL_DIR}.tar.gz"
export PORT_TARBALL_DEPS="curl gzip make m4 perl makeinfo"

PORT_GIT_DIR=m4
export PORT_GIT_URL="https://github.com/autotools-mirror/${PORT_GIT_DIR}.git"
export PORT_GIT_DEPS="git make m4 help2man perl makeinfo xz"

export PORT_EXTRA_LDFLAGS=""

if [ "${PORT_TYPE}x" = "TARBALLx" ]; then
	export PORT_BOOTSTRAP=skip
	export PORT_EXTRA_CFLAGS="-qnose -I${PORT_ROOT}/${PORT_TARBALL_DIR}/lib,${PORT_ROOT}/patches/PR1/include,/usr/include"
else
	export PORT_EXTRA_CFLAGS="-qnose -I${PORT_ROOT}/${PORT_GIT_DIR}/lib,${PORT_ROOT}/patches/PR1/include,/usr/include"
fi
