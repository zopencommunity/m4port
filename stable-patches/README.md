builtin.c.patch            
- when a child process is run in m4, we want to ensure the I/O is in ASCII when in 
  ASCII mode so we need to get the file descriptor and tag it as ASCII (otherwise it will
  default to EBCDIC)
- when a temporary file is created in m4, it is first created as an empty file and then written
  to. If the file will contain ASCII text data (which is typically the case), it needs to be 
  tagged as ASCII. This change does that tagging. It could potentially be wrong if the file is
  going to be written to later as binary - this seems the lesser of two evils but needs to be
  investigated.

