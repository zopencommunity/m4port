#!/bin/sh 
#
# Pre-requisites: 
#  - cd to the directory of this script before running the script   
#  - ensure you have sourced setenv.sh, e.g. . ./setenv.sh
#  - ensure you have GNU make installed (4.1 or later)
#  - ensure you have access to c99
#  - ensure you have an m4 bootstrap program available under M4_BOOTSTRAP_ROOT
#  - either pre-install the M4 tar ball into M4_ROOT or have curl/gunzip installed for auto-download
#
#set -x

if [ "${M4_ROOT}" = '' ]; then
	echo "Need to set M4_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${M4_BOOTSTRAP_ROOT}" = '' ]; then
	echo "Need to set M4_BOOTSTRA_PROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${M4_VRM}" = '' ]; then
	echo "Need to set M4_VRM - source setenv.sh" >&2
	exit 16
fi

if ! make --version >/dev/null 2>&1 ; then
	echo "You need GNU Make on your PATH in order to build M4" >&2
	exit 16
fi

if ! whence c99 >/dev/null ; then
	echo "c99 required to build M4. " >&2
	exit 16
fi

if ! ${M4_BOOTSTRAP_ROOT}/bin/m4 --version >/dev/null 2>&1; then
	echo "bootstrap m4 required to build M4. " >&2
	exit 16
fi

cd "${M4_ROOT}" || exit 99

if [ "${M4_VRM}" = "m4" ]; then
	if [ "${M4_BRANCH}" = '' ]; then
		echo "Need to set M4_BRANCH - source setenv.sh" >&2
		exit 16
	fi
	if ! [ -d "${M4_VRM}" ] ; then 
		if ! git clone "${AUTOTOOLS_MIRROR}/${M4_VRM}.git" ; then
			exit 4
		fi
		cd "${M4_VRM}" || exit 99
		if ! git checkout "${M4_BRANCH}" ; then
			echo "Unable to checkout branch ${M4_BRANCH}" >&2
			exit 4
		fi
		cd "${M4_ROOT}" || exit 99
	fi
else
	# Non-dev - get the tar file
	if [ "${M4_URL}" = '' ]; then
		echo "Need to set M4_URL - source setenv.sh" >&2
		exit 16
	fi

	rm -rf "${M4_VRM}"
	if ! mkdir -p "${M4_VRM}"; then
		echo "Unable to make root M4 directory: ${M4_ROOT}/${M4_VRM}" >&2
		exit 16
	fi

	if ! [ -f "${M4_VRM}.tar" ]; then
		echo "m4 tar file not found. Attempt to download with curl" 
		if ! whence curl >/dev/null ; then
			echo "curl not installed. You will need to upload M4, or install curl/gunzip from ${M4_URL}" >&2
			exit 16
		fi	
		if ! whence gunzip >/dev/null ; then
			echo "gunzip required to unzip M4. You will need to upload M4, or install curl/gunzip from ${M4_URL}" >&2
			exit 16
		fi	
		if ! (rm -f ${M4_VRM}.tar.gz; curl -s --output ${M4_VRM}.tar.gz http://ftp.gnu.org/gnu/m4/${M4_VRM}.tar.gz) ; then
			echo "curl failed with rc $rc when trying to download ${M4_VRM}.tar.gz" >&2
			exit 16
		fi	
		chtag -b ${M4_VRM}.tar.gz
		if ! gunzip ${M4_VRM}.tar.gz ; then 
			echo "gunzip failed with rc $rc when trying to unzip ${M4_VRM}.tar.gz" >&2
			exit 16
		fi	
	fi

	tar -xf "${M4_VRM}.tar" 2>/dev/null
#
# TBD: figure out how to untar the tar file without errors about setting uid/gid
#
	if [ $? -gt 1 ]; then
		echo "Unable to untar M4 drop: ${M4_VRM}" >&2
		exit 16
	fi
fi

if ! chtag -R -h -t -cISO8859-1 "${M4_VRM}"; then
	echo "Unable to tag M4 directory tree as ASCII" >&2
	exit 16
fi

DELTA_ROOT="${PWD}"

cd "${M4_ROOT}/${M4_VRM}" || exit 99

#
# Apply patches
#
if [ "${M4_VRM}" = "m4-1.4.19" ]; then
	patch -c lib/canonicalize-lgpl.c <${M4_ROOT}/patches/canonicalize-lgpl.patch
	if [ $? -gt 0 ]; then
		echo "Patch of M4 tree failed (canonicalize-lgpl)." >&2
		exit 16
	fi
	patch -c src/builtin.c <${M4_ROOT}/patches/builtin.patch
	if [ $? -gt 0 ]; then
		echo "Patch of M4 tree failed (builtin)." >&2
		exit 16
	fi
fi

export PATH="${M4_BOOTSTRAP_ROOT}/bin:${PATH}"

if [ "${M4_VRM}" = "m4" ]; then
	./bootstrap
	if [ $? -gt 0 ]; then
		echo "Bootstrap of M4 dev-line failed." >&2
		exit 16
	fi
fi

#
# Setup the configuration so that the system search path looks in lib and include ahead of the standard C libraries
#
./configure CC=c99 CFLAGS="-qlanglvl=extc1x -qascii -D_OPEN_THREADS=3 -D_UNIX03_SOURCE=1 -DNSIG=39 -D_AE_BIMODAL=1 -D_XOPEN_SOURCE_EXTENDED -D_ALL_SOURCE -D_ENHANCED_ASCII_EXT=0xFFFFFFFF -D_OPEN_SYS_FILE_EXT=1 -D_OPEN_SYS_SOCK_IPV6 -D_XOPEN_SOURCE=600 -D_XOPEN_SOURCE_EXTENDED  -qnose -qfloat=ieee -I${M4_ROOT}/${M4_VRM}/lib,${DELTA_ROOT}/include,/usr/include" --prefix="${M4_INSTALL_PREFIX}" --disable-dependency-tracking
if [ $? -gt 0 ]; then
	echo "Configure of M4 tree failed." >&2
	exit 16
fi

cd "${M4_ROOT}/${M4_VRM}" || exit 99
if ! make ; then
	echo "MAKE of M4 tree failed." >&2
	exit 16
fi

cd "${DELTA_ROOT}/tests"
export PATH="${M4_ROOT}/${M4_VRM}/src:${PATH}"

if ! ./runbasic.sh ; then
	echo "Basic test of M4 failed." >&2
	exit 16
fi
if ! ./runexamples.sh ; then
	echo "Example tests of M4 failed." >&2
	exit 16
fi

cd "${M4_ROOT}/${M4_VRM}" || exit 99
if ! make install ; then
	echo "Make install of M4 failed." >&2
	exit 16
fi

echo "M4 installed into ${M4_INSTALL_PREFIX}"

exit 0
