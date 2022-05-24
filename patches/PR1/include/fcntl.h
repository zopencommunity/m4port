#ifndef __AUTOTOOL_FCNTL__
	#define __AUTOTOOL_FCNTL__ 1

	#define O_SEARCH 0x1000
	#define O_DIRECTORY 0x2000
	#define O_CLOEXEC 0x4000

	#include_next <fcntl.h>
#endif
