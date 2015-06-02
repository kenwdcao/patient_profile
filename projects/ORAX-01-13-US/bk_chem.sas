/*
    Program Name: CHEM.sas
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Initial Date; 2013/12/03
*/

%include '_setup.sas';

data chem0;
    set source.lab_resultsresults;
    where upcase(scan(lbtest_label, 1, '-')) = 'CHEMISTRY';
    attrib
        lborres2    length = 8
        lbtest2     length = $200
        lbdtc       length = $20
        visit2      length = $200
    ;
    %subjid;
    lborres2   = input(coalescec(lborres, lbstresc), best.);
/*    lbtest2    = strip(scan(lbtest_label, 2, '-'));\*/
    lbtest2    = substr(lbtest_label, 13);

    lbdtc      = lbdt;
    lbdtn      = input(lbdt, mmddyy10.);
    visit2     = visit_label;
    keep subjid lbtest lbtest2 lborres2 lbdtc lbdtn visit2;
run;

%sort(indata = chem0, sortkey = subjid lbdtn lbdtc visit2 lbtest lbtest2);

proc transpose data = chem0 out = chem1(drop = _name_);
    by subjid lbdtn lbdtc visit2;
    id lbtest;
    idlabel lbtest2;
    var lborres2;
run;

data _base_1 _base_2;
    set chem1;
    if  strip(upcase(visit2)) in ('BASELINE') then output _base_1;
		else if strip(upcase(visit2)) in ('SCREENING') then output _base_2;
    keep subjid  _: VISIT2 ;
run;

%macro screenvar(var=);
	%do i=15 %to 36;
	s&var&&i=&var&&i;
	%end;
%mend;
	
data _base_3;
	set _base_2;
 %screenvar(var=_);
 drop _:;
run;

data _base_4 _base_5;
	set _base_3;
	if subjid='02-03' and s_26^=. then output _base_4;
		else output _base_5;
run;

data _base_4;
	set _base_4 (rename=s_26=ss_26);
keep subjid ss_26;
run;

data _base_6;
	merge _base_4 _base_5;
	by subjid;
	if s_26=. then s_26=ss_26;
	drop ss_26 visit2;
run;


/**/
/*data _base_1;*/
/*    set chem1;*/
/*    where strip(upcase(visit2)) in ('BASELINE','SCREENING');*/
/*	if upcase(visit2) = 'BASELINE' then ord=1;*/
/*		else if upcase(visit2) = 'SCREENING' then ord=2;*/
/*    keep subjid  _: VISIT2 ord;*/
/*run;*/

data _base_7;
	merge _base_1 _base_6;
	by subjid;
run;

%macro nonmiss(var=);
	%do i=15 %to 36;
	&var&&i=coalesce(&var&&i,s&var&&i);
	%end;
%mend;

data _base;
	set _base_7;

	%nonmiss(var=_);

	drop s_:;
run;

data _max _min _last;
    set chem1;
        by subjid;
    length max1 - max100 min1 - min100 last1 - last100 8; /*100 is an arbitary number which is larger than # of chem test*/
    retain max1 - max100 min1 - min100 last1 - last100 ;
    array maxl{100} max1-max100;
    array minl{100} min1-min100;
    array last{100} last1-last100;
    array chem{*} _:;
    if first.subjid then
        do i = 1 to dim(chem);
           maxl[i] = chem[i]; 
           minl[i] = chem[i];
           last[i] = chem[i];
        end;
    else 
        do i = 1 to dim(chem);
           if nmiss(maxl[i],chem[i])<2 then maxl[i] = max(maxl[i], chem[i]);
           if nmiss(minl[i],chem[i])<2 then minl[i] = min(minl[i], chem[i]);
            last[i] = coalesce(chem[i], last[i]);

        end;
    if last.subjid then 
        do;
            do i = 1 to dim(chem);
                chem[i] = last[i];
            end;
            output _last;
            do i = 1 to dim(chem);
                chem[i] = maxl[i];
            end;
            output _max;
            do i = 1 to dim(chem);
                chem[i] = minl[i];
            end;
            output _min;
        end;
   
    keep subjid  _:;
run;

data chem2;
    set _base (in = a)
        _min  (in = b)
        _max  (in = c)
        _last (in = d)
    ;
    by subjid;
    
    attrib 
        type    length = $40   label = 'Laboratory#(Chemistry)'
    ;
    if a then type = 'Baseline';
    else if b then type = 'Lowest';
    else if c then type = 'Highest';
    else if d then type = 'Last';
run;

proc sql;
    create table _mockup0 as
    select distinct subjid
    from chem2
    ;
quit;

data _mockup;
    set _mockup0;
    attrib 
        type    length = $40   label = 'Laboratory#(chemtology)'
    ;
    
    type = 'Baseline'; __ord = 1; output;
    type = 'Lowest';   __ord = 2; output;
    type = 'Highest';  __ord = 3; output;
    type = 'Last';     __ord = 4; output;
run;

%sort(indata = chem2,   sortkey = subjid type);
%sort(indata = _mockup, sortkey = subjid type);

data chem3;
    merge chem2 _mockup;
        by subjid type;
    format _numeric_ na.;
run;

%sort(indata = chem3, sortkey = subjid __ord);

data pdata.chem1;
    retain subjid type _21 _20 _30 _19 _28 _17 _26 _24;
    set chem3;
    keep subjid type _21 _20 _30 _19 _28 _17 _26 _24;
	format _all_;

run;

data pdata.chem2;
    retain subjid type _34 _33 _16 _15 _23 _35 _25;
    set chem3;
    keep subjid type _34 _33 _16 _15 _23 _35 _25;
	format _all_;

run;

data pdata.chem3;
    retain subjid type _27 _18 _22 _27 _29 _31 _32 _36;
    set chem3;
    keep subjid type _27 _18 _22 _27 _29 _31 _32 _36;
	format _all_;

run;
