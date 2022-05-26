esyscmd(`echo "jello" | grep "hello world' ")ifelse(sysval, `0',
       `errprint(` skipping: system does not allow closing stdout
')m4exit(`77')')dnl
sysval
