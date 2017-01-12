%macro separate_patient(dataset, PANVar);
/***************************************************************************
This doesn't happen very often. Sometimes we need each participant in each sheet
and these should be in a single excel file. If the code doesn't run, please check
sas hotfix.
***************************************************************************/
proc sql noprint;
	select name, encounter_number into :name1-:name&total., :pan1-:pan&total. 
	from cohort;
quit;


%do loop = 1 %to &total.;
*loop through all patients;

data dummy;
	set &dataset.;
	where &PANVar. = strip("&&pan&loop.");
	call missing(pt_id); *de-identify variables;
  drop &PANVar.;
run;

proc export data = dummy
	outfile = "&current.\&dataset..xlsx"
	dbms = xlsx
	label;
	sheet = "&&name&loop.";
run;

proc sql;
	drop table dummy;
quit;
%end;
%mend separate_patient;
