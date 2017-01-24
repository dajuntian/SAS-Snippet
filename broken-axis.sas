*create a sample data;
/*********************************************************
This is a modification of http://support.sas.com/kb/24/909.html
======================And the log is not clean=====
*************************************************************/
data baseball;
    set sashelp.baseball;
    output;
    nHits = nHits + 1000;
    output;
output;
run;

axis1 order = (0 to 300 by 50, 1000 to 1300 by 50);

data anno;
   length function style color $8;
   retain xsys '5' ysys '2'  when 'a' style 'solid';

	                function = 'move'; xsys = '1'; x = -1;   ysys = '1'; y = 49; output;
   color = 'white';   function = 'bar';  x = 3; y = 51; output;
   color = 'white'; function = 'move'; xsys = '2'; x = 100; ysys = '2'; y = 300; output;
   color = 'white'; function = 'draw'; xsys = 'B'; x = 0;   ysys = 'B'; y = 3.1;  output;
   color = 'black'; function = 'draw'; xsys = 'B'; x = -1.3;   ysys = 'B'; y = -1.3;  output;
   color = 'white'; function = 'draw'; xsys = 'B'; x = 0;   ysys = 'B'; y = 1.3;  output;
   color = 'black'; function = 'draw'; xsys = 'B'; x = 1.3;   ysys = 'B'; y = 1.3;  output;

axis1 order = (0 to 300 by 50, 1000 to 1300 by 50);
proc gplot data = baseball;
	plot nHits * nAtBat / vaxis = axis1 anno = anno;
run;
quit;
