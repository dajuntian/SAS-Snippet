%macro assign_folder;
	%global current upper uppest;
	%if &sysscp. = WIN %then %do;
		/*beginning within windows platform*/
		%let current = %sysfunc(prxchange(s/(.+?)([^\\]+\.sas)/$1/i, 1, %sysget(SAS_EXECFILEPATH)));
		%let upper = %sysfunc(prxchange(s/(.+?)([^\\]+\\)([^\\]+\.sas)/$1/i, 1, %sysget(SAS_EXECFILEPATH)));
		%let uppest = %sysfunc(prxchange(s/(.+?)([^\\]+\\)([^\\]+\\)([^\\]+\.sas)/$1/i, 1, %sysget(SAS_EXECFILEPATH)));
		/*ending of within windows platform*/
	%end;
	%else %if &sysscp. = LIN X64 %then %do;
		/*sas studio in non-interactive mode*/
		/**************beginning of sas studio specific codes*****************************/
		%let filepath = &_SASPROGRAMFILE;
		*set the macro variable for path;
		%let current = %sysfunc(prxchange(s/(.+?)([^\/]+\.sas)/$1/i, 1, &filepath.));
		%let upper = %sysfunc(prxchange(s/(.+?)([^\/]+\/)([^\/]+\.sas)/$1/i, 1, &filepath.));
		%let uppest = %sysfunc(prxchange(s/(.+?)([^\/]+\/)([^\/]+\/)([^\/]+\.sas)/$1/i, 1, &filepath.));
		/**************ending of sas studio specific codes*****************************/
	%end;
	%else %do;
		%put ERROR: neither Linux nor Windows;
	%end;
	%put &current.;
	%put &upper.;
	%put &uppest.;
	%put &SYSSCP.;
	%put &SYSSCPL.;
%mend assign_folder;
%assign_folder
;;;
