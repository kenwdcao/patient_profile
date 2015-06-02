%include '_setup.sas';

data eos1;
  length DEATHYN $10 DSREASN $200 DISCDT $40;
  set source.study_end;
  %subjid;
  if DSCOMP_LABEL = 'No' and dtcddt^='' then discdt =strip(put(input(dtcddt, mmddyy10.), yymmdd10.));
  if DSREAS_LABEL ^='' and DSREASP^='' then DSREASN = strip(DSREAS_LABEL)||': '||strip(DSREASP); 
     else if DSREAS_LABEL ^='' then DSREASN = strip(DSREAS_LABEL);
        else DSREASN = '';
  if index(DSREAS_LABEL, 'Death')>0 or DEATHDT^='' then DEATHYN = 'Y';
    else DEATHYN = '';
  if DEATHDT^='' and index(DEATHDT, '/')>0 then DEATHDT = strip(put(input(DEATHDT, mmddyy10.), yymmdd10.));
run;

*Derive StudyDay and Cycle#Day#*;
data eos2;
   length subjid $20 __fdosedt 8  DISCDTC DEATHDTC CYCLE DAY $40 DEATHREL COMMENT $200;
   keep SUBJID DISCDTC DSREASN DEATHYN DEATHDTC DEATHREL COMMENT CYCLE DAY; 
    if _n_ = 1 then
        do;
            declare hash h (dataset: 'pdata.dm');
            rc = h.defineKey('subjid');
            rc = h.defineData('__fdosedt');
            rc = h.defineDone();
            call missing(subjid, __fdosedt);
        end;
    set eos1;
    rc = h.find();
    call missing(_dy);  %dy(discdt, yymmdd10.); discdy=_dy;
    call missing(_dy);  %dy(deathdt, yymmdd10.); deathdy=_dy;

  if discdy^=. then DISCDTC = 'Day '||strip(put(discdy, best.));
     else if discdt^='' then DISCDTC = strip(discdt);
        else if discdt = '' then DISCDTC = '';
   if deathdt ^='' and deathdy^=. then deathdtc= '('||strip(deathdt)||') /Day '||strip(put(deathdy, best.));
      else if deathdt^='' then deathdtc= '('||strip(deathdt)||')';
	    else deathdtc = '';
    *leave "Death Related" and "Comments" blank temporarily*;
    DEATHREL = '';
    COMMENT = '';
    *Derive Cycle#Day#*;
    if discdt^='' and dtcddt^='' and __fdosedt^=. then do; cycle = strip(put(ceil((input(dtcddt, mmddyy10.)-__fdosedt +1)/35), best.)); 
	   if input(dtcddt, mmddyy10.)=__fdosedt then day='1';   else if mod((input(dtcddt, mmddyy10.)-__fdosedt+1), 35) = 0 then day='35';
              else day=strip(put(mod((input(dtcddt, mmddyy10.)-__fdosedt+1), 35), best.)); end;

	label DISCDTC = 'Date of Discontinuation'
			CYCLE = 'Cycle'
			DAY = 'Day'
			DSREASN = 'Reason of Study Stopped'
			DEATHYN = 'Subject Died'
			DEATHDTC = 'Date of Death'
            DEATHREL = 'Death Related'
			COMMENT = 'Comments';
run;

proc sql;
  create table eos3 as
  select * from eos2 where subjid in (select distinct subjid from pdata.dm)
  order by subjid;
quit;

data pre_eos;
    length col $1024;
    set eos3;
    %concat(invars = DISCDTC , outvar = col); output;
    %concat(invars = CYCLE DAY, outvar = col); output;
    %concat(invars = DSREASN , outvar = col); output;
    %concat(invars = DEATHYN DEATHDTC , outvar = col); output;
    %concat(invars = DEATHREL , outvar = col); output;
    %concat(invars = COMMENT , outvar = col); output;
run;

data pre_eos1;
    set pre_eos(rename=(col = in_col)) ;
    by subjid;
    length col $1024;
    retain col;
    if first.subjid then col = in_col;
    else col = strip(col) || "&escapechar.2n" || in_col;
    if last.subjid then output;
    
    drop in_col;
run;

data pdata.eos(label = 'End of Study');
   retain subjid col;
   set pre_eos1;
   keep subjid col;
run;


