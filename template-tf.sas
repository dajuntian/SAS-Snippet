options symbolgen;
%let dir = C:\SAS code to get table 1;
libname sdtm "&dir." access = readonly;


*the first part define the template;
proc template;
    define style tfl_table;
        style body/
            leftmargin = 0.5in
            rightmargin = 0.5in
            topmargin = 1in
            bottommargin = 1in;
        style table /
            frame = hsides
            rules = groups
            cellpadding = 3pt
            cellspacing = 0pt
            width = 100%;
        style header /
            /*This is the header line for the table.*/
            fontfamily = 'Courier New'
            asis = off
            fontsize = 9pt;
        style data /
            /*This is the data in the table.*/
            fontfamily = 'Courier New'
            fontsize = 9pt
            asis = on;
        style TableFooterContainer /
            borderbottomcolor = white;
        style TitlesAndFooters  /
            fontfamily = 'Courier New'
            textalign = left
            fontsize = 10pt;
        style systemfooter /
            /*This affects the text in footnoteX statement.*/
            textalign = left
            fontfamily = 'Courier New'
            fontsize = 9pt;
        style NoteContent from Note /
            /*change the font in the compute line*/
            textalign = left
            fontsize = 9pt
            fontfamily = 'Courier New'
            asis = on;
    end;
run;
*end of defining the template;




*get some randomly generated data;
data adsl;
    set sdtm.adsl;
    array measure {*} AGE HEIGHT PULSE SYSBP WEIGHT;
    do i = 1 to dim(measure);
        measure[i] = measure[i] + rand('NORMAL', 10, 20);
    end;

    *random sex;
    array array_sex {2} $  _temporary_ ('F', 'M');
    sex = array_sex[ranbin(0, 1, ranuni(0)) + 1];

    *random treatment;
    array array_trt{3} $ _temporary_ ('WONDER10', 'WONDER20', 'PLACEBO');
    ARMCD = array_trt{rand('TABLE', 0.3, 0.3, 0.4)};

    array array_race{4} $40 _temporary_ ('BLACK OR AFRICAN AMERICAN', 'MULTIPLE', 'WHITE', 'OTHER');
    RACE = array_race{rand('TABLE', 0.3, 0.2, 0.3, 0.2)};
    output;
    ARMCD = 'TOTAL';
    output;
run;

proc sort data = adsl;
    by ARMCD;
run;

data adsl;
    set adsl;
    keep AGE HEIGHT WEIGHT ARMCD SEX RACE;
run;

proc means data = adsl n mean median std min max;
    var AGE HEIGHT WEIGHT;
    by ARMCD;
    output out = adsl_means;
run;

*transpose the means data;
proc transpose data = adsl_means out = adsl_means_t;
    by ARMCD _STAT_ notsorted;
    var AGE HEIGHT WEIGHT;
run;    

proc sort data = adsl_means_t;
    by _stat_ _name_;
run;


*change the numeric col1 to str;
data adsl_means_t;
    set adsl_means_t;
    if _STAT_ = "N" then col1_char = strip(put(col1, best32.));
    else col1_char = strip(put(col1, 8.2));
run;

proc transpose data = adsl_means_t out = adsl_means_t_t;
    by _stat_ _NAME_ _LABEL_;
    id armcd;
    var col1_char;
run;

data adsl_means_t_t;
    set adsl_means_t_t;
    group = _STAT_;
    test = _NAME_;
run;
*calculate the frequency;

proc freq data = adsl;
    by armcd;
    tables sex / out = adsl_freq_sex;
run;

proc freq data = adsl;
    by armcd;
    tables race / out = adsl_freq_race;
run;

data adsl_freq;
    length test $8;
    set adsl_freq_sex adsl_freq_race;
    if missing(sex) then test = 'RACE';
    else test = 'SEX';
    group = cats(sex, race);
    value = cats(put(COUNT, best32.), '(', put(PERCENT, 5.2), '%)');
run;

proc sort data = adsl_freq;
    by test group  armcd;
run;

proc transpose data = adsl_freq out = adsl_freq_t;
    by test group;
    id armcd;
    var value;
run; 

*define the order;


data adsl_table;
    set adsl_freq_t adsl_means_t_t;
    keep test group WONDER10 WONDER20 PLACEBO TOTAL;
run;

proc sort data = adsl_table;
    by test group;
run;

*get the n for each group;
proc sql noprint;
    select count(*) into :trt1 trimmed from adsl where armcd = 'PLACEBO';
    select count(*) into :trt2 trimmed from adsl where armcd = 'WONDER10';
    select count(*) into :trt3 trimmed from adsl where armcd = 'WONDER20';
    select count(*) into :trt4 trimmed from adsl where armcd = 'TOTAL';
quit;

*use report to report the value;
options orientation = portrait nodate nonumber;
ods escapechar = '^';
ods tagsets.rtf file = "&dir.\demog 2015-10-15.rtf" style = tfl_table;
Title1 "Table 1. Demographics characteristics for wonder study.";
Footnote1 "^{super a} :This is done by CBMI in 2016.";
proc report data = adsl_table nowd out = debug_adsl_table split = '|'; 
    column test group 
        ("Characteristics" header) 
        ("Placebo|(n=&trt1.)" placebo )
        ("^R'\brdrb\brdrs\brdrw2 'Wonder Treatment" 
            ("10 mg/d | (n=&trt2.)" wonder10) 
            ("20 mg/d | (n=&trt3.)" wonder20)
        )
        ("Total|(n=&trt4.)" total);
    define test / order noprint;
    define group / noprint;
    define header / '' computed;
    define placebo /'' style = {pretext = "^R'\tqdec\tx350 '"};
    define wonder10 / '' style = {pretext = "^R'\tqdec\tx350 '"};
    define wonder20 / '' style = {pretext = "^R'\tqdec\tx350 '"};
    define total / "" style = {pretext = "^R'\tqdec\tx350 '"};
    break before test / summarize;
    compute header / character length = 40;
        if _break_ = 'test' then header = test;
        else header = "^{nbspace 2}" || group;
    endcomp;
run;

ods tagsets.rtf close;
