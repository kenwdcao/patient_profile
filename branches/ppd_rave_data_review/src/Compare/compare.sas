/*******************************************************************************************************
 Program Nmae: Compare.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/07
 
 Compare processed datasets for patient profiles
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*******************************************************************************************************/

%macro compare(config);

%local rc;
%local cfgfilrf;

%if &compare = N %then %return;

** write a configuration file for macro sasDsetCompare;
%let cfgfilrf = cmpcfg;
%let rc = %sysfunc(filename(cfgfilrf, &tempdir\config-compare.txt));
data _null_;
    set &config;
    file &cfgfilrf;
    put dset ' : ' keylist ' :';
run;
%let rc = %sysfunc(filename(cfgfilrf));


** call macro sasDsetCompare;
%sasDsetCompare(
       olddir = &pdatabkdir, 
       newdir = &pdatadir, 
       outdir = &tempdir,
    genReport = Y,
       config = &tempdir\config-compare.txt
);

%mend compare;
