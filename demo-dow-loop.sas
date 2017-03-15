
data air;
	set sashelp.air;
	year = year(date);
run;

*sort by year;
proc sort data = air;
	by year;
run;

data mean;
	do until(last.year);
		set air;
		by year;
		total = sum(air, total);
	end;
	keep year total;
  put _all_;
run;

proc print data = mean;
run;



