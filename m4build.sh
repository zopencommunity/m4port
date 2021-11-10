#!/bin/sh 
#
# Pre-requisites: 
#  - cd to the directory of this script before running the script   
#  - ensure you have sourced setenv.sh, e.g. . ./setenv.sh
#  - ensure you have GNU make installed (4.1 or later)
#  - ensure you have access to c99
#  - either pre-install the M4 tar ball into M4_ROOT or have curl/gunzip installed for auto-download
#
if [ "${M4_ROOT}" = '' ]; then
	echo "Need to set M4_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${M4_VRM}" = '' ]; then
	echo "Need to set M4_VRM - source setenv.sh" >&2
	exit 16
fi

make --version >/dev/null 2>&1 
if [ $? -gt 0 ]; then
	echo "You need GNU Make on your PATH in order to build M4" >&2
	exit 16
fi

whence c99 >/dev/null
if [ $? -gt 0 ]; then
	echo "c99 required to build M4. " >&2
	exit 16
fi

MY_ROOT="${PWD}"

if [ "${M4_VRM}" != "m4" ]; then
	# Non-dev - get the tar file
	rm -rf "${M4_ROOT}/${M4_VRM}"
	mkdir -p "${M4_ROOT}/${M4_VRM}"
	if [ $? -gt 0 ]; then
		echo "Unable to make root M4 directory: ${M4_ROOT}/${M4_VRM}" >&2
		exit 16
	fi
	cd "${M4_ROOT}"
	M4_ROOT="${PWD}"

	if ! [ -f "${M4_VRM}.tar" ]; then
		URL="http://ftp.gnu.org/gnu/m4/"
		echo "m4 tar file not found. Attempt to download with curl" 
		whence curl >/dev/null
		if [ $? -gt 0 ]; then
			echo "curl not installed. You will need to upload M4, or install curl/gunzip from ${URL}" >&2
			exit 16
		fi	
		whence gunzip >/dev/null
		if [ $? -gt 0 ]; then
			echo "gunzip required to unzip M4. You will need to upload M4, or install curl/gunzip from ${URL}" >&2
			exit 16
		fi	
		(rm -f ${M4_VRM}.tar.gz; curl -s --output ${M4_VRM}.tar.gz http://ftp.gnu.org/gnu/m4/${M4_VRM}.tar.gz)
		rc=$?
		if [ $rc -gt 0 ]; then
			echo "curl failed with rc $rc when trying to download ${M4_VRM}.tar.gz" >&2
			exit 16
		fi	
		chtag -b ${M4_VRM}.tar.gz
		gunzip ${M4_VRM}.tar.gz
		rc=$?
		if [ $rc -gt 0 ]; then
			echo "gunzip failed with rc $rc when trying to unzip ${M4_VRM}.tar.gz" >&2
			exit 16
		fi	
	fi

	tar -xf "${M4_VRM}.tar"
	if [ $? -gt 0 ]; then
		echo "Unable to make untar M4 drop: ${M4_VRM}" >&2
		exit 16
	fi
else
	cd "${M4_ROOT}"
	M4_ROOT="${PWD}"
fi
chtag -R -h -t -cISO8859-1 "${M4_VRM}"
if [ $? -gt 0 ]; then
	echo "Unable to tag M4 directory tree as ASCII" >&2
	exit 16
fi

DELTA_ROOT="${PWD}"

cd "${M4_ROOT}/${M4_VRM}"

#
# Apply patches
#
if [ "${M4_VRM}" = "m4-1.4.19" ]; then
	patch -c lib/canonicalize-lgpl.c <${MY_ROOT}/patches/canonicalize-lgpl.patch
	if [ $? -gt 0 ]; then
		echo "Patch of M4 tree failed (canonicalize-lgpl)." >&2
		exit 16
	fi
	patch -c src/builtin.c <${MY_ROOT}/patches/builtin.patch
	if [ $? -gt 0 ]; then
		echo "Patch of M4 tree failed (builtin)." >&2
		exit 16
	fi
fi

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
./configure CC=c99 CFLAGS="-qlanglvl=extc1x -qascii -D_OPEN_THREADS=3 -D_UNIX03_SOURCE=1 -DNSIG=39 -qnose -I${M4_ROOT}/${M4_VRM}/lib,${DELTA_ROOT}/include,/usr/include"
if [ $? -gt 0 ]; then
	echo "Configure of M4 tree failed." >&2
	exit 16
fi

cd "${M4_ROOT}/${M4_VRM}"
make
if [ $? -gt 0 ]; then
	echo "MAKE of M4 tree failed." >&2
	exit 16
fi


cd "${DELTA_ROOT}/tests"
export PATH="${M4_ROOT}/${M4_VRM}/src:${PATH}"

./runbasic.sh
if [ $? -gt 0 ]; then
	echo "Basic test of M4 failed." >&2
	exit 16
fi
./runexamples.sh
if [ $? -gt 0 ]; then
	echo "Example tests of M4 failed." >&2
	exit 16
fi
exit 0
