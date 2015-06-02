%include '_setup.sas';

data mh;
  retain SUBJID MHSPID DIAG DIAGDT_MIN RESDT_MAX ONGOING;
  keep SUBJID MHSPID DIAG DIAGDT_MIN RESDT_MAX ONGOING SPID;
  length mhspid $20 ongoing $1;
  set source.med_histhistory;
  where diag^='';
  %subjid;
  if item_group_repeat_key^='' then mhspid = strip(item_group_repeat_key);
  if item_group_repeat_key^='' then spid = input(strip(item_group_repeat_key), best.);
  if continuing_label = 'Yes' then ongoing = 'Y';
    else if continuing_label = 'No' then ongoing = 'N';
  if DIAGDT_MIN^='' then DIAGDT_MIN = strip(put(input(DIAGDT_MIN, mmddyy10.), yymmdd10.));
  if RESDT_MAX^='' then RESDT_MAX = strip(put(input(RESDT_MAX, mmddyy10.), yymmdd10.));
  label mhspid = 'No.'
		 diag = 'Diagnosis'
         diagdt_min = 'Onset Date'
		 resdt_max = 'End Date'
		 ongoing = 'Ongoing?';
run;

proc sql;
  create table mh1 as
  select * from mh where subjid in (select distinct subjid from pdata.dm)
  order by subjid, spid;
quit;

data pdata.mh(label = 'Medical History');
  set mh1;
  keep SUBJID MHSPID DIAG DIAGDT_MIN RESDT_MAX ONGOING;
run;
