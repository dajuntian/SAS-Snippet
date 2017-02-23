/***************************************************************************************************************************
This is used to generate a list of values separated by ',', which could be used in sql in operation;
*example: 
data demo;
	do x = 1 to 10;
		y = '111';
		y2 = x;
		if x = 3 then do; y = ""; y2 = .; end;
		output;
	end;
run;

%comma_copy(demo, y2, output.txt, horizental = 1)
%comma_copy(demo, y2, output.txt)
;;;
***************************************************************************************************************************/

%macro comma_copy(inds, var, outfile, horizental = 0);
data _null_;
	file "&outfile." 
		%if &horizental. = 1 %then %do; RECFM = N %end; ;
	set &inds. end = last;
	*exclude missing records for the input variable;
	where not missing(&var.);
	vartype = vtype(&var.);
	if vartype = 'C' then do;
		*generate output item for character;
		c_out = cats("'", &var., "'", ",");
		c_out_last = cats("'", &var., "'");
	end;
	if vartype = 'N' then do;
		*generate output item for numeric;
		c_out = cats(&var., ",");
		c_out_last = cats(&var.);
	end;
	if last then put c_out_last;
	else put c_out;
run;
%mend comma_copy;

