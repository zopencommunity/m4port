syscmd(`echo | cat >&7 2>/dev/null')ifelse(sysval, `0',
       `errprint(` skipping: system does not allow closing stdout
')m4exit(`77')')dnl
changequote(`[', `]')dnl
syscmd([echo | ']__program__[' >&-])dnl
sysval
