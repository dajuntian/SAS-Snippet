%macro assign_folder;
	%global current upper uppest filepath;
	%if &sysscp. = WIN %then %do;
		/*beginning within windows platform*/
		%let filepath = %sysget(SAS_EXECFILEPATH);
		%let current = %sysfunc(prxchange(s/(.+?)([^\\]+\.sas)/$1/i, 1, &filepath.));
		%let upper = %sysfunc(prxchange(s/(.+?)([^\\]+\\)([^\\]+\.sas)/$1/i, 1, &filepath.));
		%let uppest = %sysfunc(prxchange(s/(.+?)([^\\]+\\)([^\\]+\\)([^\\]+\.sas)/$1/i, 1, &filepath.));
		/*ending of within windows platform*/
	%end;
	%else %if &sysscp. = LIN X64 or &sysscp. = LINUX %then %do;
		/*sas studio in non-interactive mode*/
		%if %Symexist(_SASPROGRAMFILE) %then %do;
			/**************beginning of sas studio specific codes*****************************/
			%let filepath = &_SASPROGRAMFILE;
			*set the macro variable for path;
			%let current = %sysfunc(prxchange(s/(.+?)([^\/]+\.sas)/$1/i, 1, &filepath.));
			%let upper = %sysfunc(prxchange(s/(.+?)([^\/]+\/)([^\/]+\.sas)/$1/i, 1, &filepath.));
			%let uppest = %sysfunc(prxchange(s/(.+?)([^\/]+\/)([^\/]+\/)([^\/]+\.sas)/$1/i, 1, &filepath.));
			/**************ending of sas studio specific codes*****************************/
		%end;
		%else %do;
			/******in linux terminal mode******/
			%macro pname;
				%global filepath ;
			    %let filepath =;	
			    data _null_;
			        set sashelp.vextfl;
			        if (substr(fileref,1,3)='_LN' or substr(fileref,1,3)='#LN' or substr(fileref,1,3)='SYS') and
			         index(upcase(xpath),'.SAS')>0 then call symput("filepath",trim(xpath));
			     run;
			%mend pname;
			%pname;
			%let current = %sysfunc(prxchange(s/(.+?)([^\/]+\.sas)/$1/i, 1, &filepath.));
			%let upper = %sysfunc(prxchange(s/(.+?)([^\/]+\/)([^\/]+\.sas)/$1/i, 1, &filepath.));
			%let uppest = %sysfunc(prxchange(s/(.+?)([^\/]+\/)([^\/]+\/)([^\/]+\.sas)/$1/i, 1, &filepath.));
			/******end of in linux terminal mode******/
		%end;
	%end;
	%else %do;
		%put ERROR: neither LIN X64 nor WIN;
	%end;
	%put current: &current.;
	%put upper: &upper.;
	%put uppest: &uppest.;
	%put sysscp: &SYSSCP.;
	%put sysscpl: &SYSSCPL.;
%mend assign_folder;
%assign_folder
;;;
