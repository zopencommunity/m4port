#!/bin/sh
#set -x

if ! [ -f ./setenv.sh ]; then
	echo "Need to source from the setenv.sh directory" >&2
else
	export _BPXK_AUTOCVT="ON"
	export _CEE_RUNOPTS="FILETAG(AUTOCVT,AUTOTAG),POSIX(ON),TERMTHDACT(MSG)"
	export _TAG_REDIR_ERR="txt"
	export _TAG_REDIR_IN="txt"
	export _TAG_REDIR_OUT="txt"

# Note to build m4 you need to either use a tarball that is pre-configured
# or clone the code from git.
# 
# If you use the pre-configured m4 source tarball, you need a 'bootstrap' m4
# and you need curl to pull down the tarball
#
# If you clone the code from git, you need to already have the Autotools installed
# on your system
#
# Specifying M4_VRM of m4-1.4.19 will take the 'tarball' path
# Specifying M4_VRM of m4 will take the 'git' path
#
	gitsource=false 
	if $gitsource ; then
		export M4_VRM="m4"
		export AUTOTOOLS_MIRROR="https://github.com/autotools-mirror"
		export M4_BRANCH="branch-1.4"
	else 
		export M4_URL="http://ftp.gnu.org/gnu/m4/"
		export M4_VRM="m4-1.4.19"
	fi
	export M4_ROOT="${PWD}"
	export fsroot=$( basename $HOME )
	export M4_BOOTSTRAP_ROOT="/${fsroot}/m4boot"
	export M4_INSTALL_PREFIX="/${fsroot}/m4prod"   

fi
