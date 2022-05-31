#!/bin/sh
#
# Set up environment variables for general build tool to operate
#
if ! [ -f ./setenv.sh ]; then
	echo "Need to source from the setenv.sh directory" >&2
	return 0
fi

export PORT_ROOT="${PWD}"
export PORT_TYPE="GIT"

PORT_TARBALL_DIR=m4-1.4.19
export PORT_TARBALL_URL="https://ftp.gnu.org/gnu/m4/${PORT_TARBALL_DIR}.tar.gz"
export PORT_TARBALL_DEPS="curl gzip make m4"

PORT_GIT_DIR=m4
export PORT_GIT_URL="https://github.com/autotools-mirror/${PORT_GIT_DIR}.git"
export PORT_GIT_DEPS="git make m4 help2man perl makeinfo xz autoconf automake"
export PORT_GIT_BRANCH="branch-1.6"

export PORT_EXTRA_LDFLAGS=""

rm patches
if [ "${PORT_TYPE}x" = "TARBALLx" ]; then
	export PORT_BOOTSTRAP=skip
	export PORT_EXTRA_CFLAGS="-qnose -I${PORT_ROOT}/${PORT_TARBALL_DIR}/lib,${PORT_ROOT}/patches/PR1/include,/usr/include/le"
	ln -s tarball-patches patches
else
	export PORT_EXTRA_CFLAGS="-qnose -fgnu89-inline -I${PORT_ROOT}/${PORT_GIT_DIR}/lib,${PORT_ROOT}/patches/PR1/include,/usr/include/le"
	ln -s git-patches patches
fi
