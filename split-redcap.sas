/***********************************************************************************
The excel file from redcap is bloody messy, at least it looks so.
So I have it separeted by intruments
*************************************************************************************/


*get concents of redcap;
proc contents data = raw.redcap out = raw_redcap_contents varnum short;
run;
proc sort data = raw_redcap_contents; by varnum; run;

data variable_complete;
	*this data set has the last varaible for each instrument;
    set raw_redcap_contents;
    where LABEL = 'Complete?';
run;
proc sort data = variable_complete;
    by varnum; 
run;

data variable_complete;
    set variable_complete;
    previous_varnum = lag(varnum);
    keep name varnum previous_varnum second_to_last_varnum number_of_variables;
    if not missing(previous_varnum) then previous_varnum = sum(previous_varnum, 1);
    else previous_varnum = 3;
    second_to_last_varnum = varnum - 1;
    number_of_variables = varnum - previous_varnum; *this count excludes the last variable xxx_complete for each instrument;
run;

*add variable name after the version;
data variable_complete;
    set variable_complete;
    /*this counts the total number of variables between xx_verstion to xx_complete, exclude two ends
      exception for screen instruent***********/
    varnum_after_version = previous_varnum + 1; 
    num_of_usefull_var = second_to_last_varnum - varnum_after_version + 1;
run;

proc sql; select (varnum - previous_varnum) as number_of from variable_complete order by number_of; quit;

proc sql;
    alter table variable_complete add previous_name char(100), second_to_last_name char(100);
    update variable_complete 
    set previous_name = 
        (select name from raw_redcap_contents where varnum = previous_varnum);
    update variable_complete 
    set second_to_last_name = 
        (select name from raw_redcap_contents where varnum = second_to_last_varnum);
    alter table variable_complete add var_after_version_name char(100);
    update variable_complete 
    set var_after_version_name = 
        (select name from raw_redcap_contents where varnum = varnum_after_version);

quit;

%macro sep_instrut(start_var, end_var, var_follow_start, second2end_var, number_of_var);
    data sdtm.&end_var. sdtm_del.&end_var.;
        set raw.&source_redcap.;
        keep subj_num  redcap_event_name &start_var.--&end_var.;
        if cmiss(of &var_follow_start.-- &second2end_var.) = &number_of_var. then output sdtm_del.&end_var.;
        else output sdtm.&end_var.;
    run;
%mend sep_instrut;

data _null_;
    set variable_complete;
    if num_of_usefull_var > 0 then 
    call execute('%sep_instrut(' || previous_name || ',' || name || ',' || var_after_version_name || ','
                 || second_to_last_name || ',' || num_of_usefull_var || ')');
    else call execute('%sep_instrut(' || previous_name || ',' || name || ',' || previous_name || ','
                 || second_to_last_name || ',' || number_of_variables || ')');;
run;
/*end of separate data by instrument*/
