builtin.c.patch            
- when a child process is run in m4, we want to ensure the I/O is in ASCII when in 
  ASCII mode so we need to get the file descriptor and tag it as ASCII (otherwise it will
  default to EBCDIC)

canonicalize-lgpl.c.patch 
- on z/OS, the __stat macro is defined and this causes a collision with the __stat macro
  used in this file. The fix is to use a different macro name that doesn't collide, so __gplstat
  was chosen.

configure.patch
- there is a typo in the argument definition of 'int main' - argv type is `char**` not `char*`
