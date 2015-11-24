*get the current fullpath of current file;
%put %sysget(SAS_EXECFILEPATH);

*get the directory of current file;
%put %sysfunc(prxchange(s/(.+?)([^\\]+\.sas)/$1/i, 1, %sysget(SAS_EXECFILEPATH)));

*get the upper level folder;
%put %sysfunc(prxchange(s/(.+?)([^\\]+\\)([^\\]+\.sas)/$1/i, 1, %sysget(SAS_EXECFILEPATH)));
