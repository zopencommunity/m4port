# zos-autotools 
Place to share information about configure/build of z/OS Autotools (only deltas to open source)

# pre-reqs
You need gmake, c99, and either manually upload the M4 tarball to your system or use curl/gunzip to do it automatically

# Build m4
```
. ./setenv.sh
./m4build.sh
```

This will generate the m4 executable in the 'src' sub-directory of the M4 tree

# Known issues

Only a very basic test has been run. Input m4 files need to be in a tagged ISO8859-1 file with auto-conversion on (see setenv.sh for expected settings)
