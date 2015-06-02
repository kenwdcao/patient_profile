/*
    Program Name: HEMA.sas
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Initial Date; 2013/12/03
*/


%include '_setup.sas';

data hema0;
    set source.lab_resultsresults;
    where upcase(scan(lbtest_label, 1, '-')) = 'HEMATOLOGY';
    attrib
        lborres2    length = 8
        lbtest2     length = $200
        lbdtc       length = $20
        visit2      length = $200
    ;
    %subjid;
    lborres2 = input(coalescec(lborres, lbstresc), best.);
    lbtest2  = strip(scan(lbtest_label, 2, '-'));
    lbdtc    = lbdt;
    lbdtn    = input(lbdt, mmddyy10.);
    visit2   = visit_label;
    keep subjid lbtest lbtest2 lborres2 lbdtc lbdtn visit2;
run;

%sort(indata = hema0, sortkey = subjid lbdtn lbdtc visit2 lbtest lbtest2);

proc transpose data = hema0 out = hema1(drop = _name_);
    by subjid lbdtn lbdtc visit2;
    id lbtest;
    idlabel lbtest2;
    var lborres2;
run;


/*data _base;*/
/*    set hema1;*/
/*    where strip(upcase(visit2)) = 'BASELINE';*/
/*    keep subjid  _:;*/
/*run;*/


data _base_1 _base_2;
    set hema1;
    if  strip(upcase(visit2)) in ('BASELINE') then output _base_1;
		else if strip(upcase(visit2)) in ('SCREENING') then output _base_2;
    keep subjid  _: VISIT2 lbdtc lbdtn;
run;

%macro screenvar(var=);
	%do i=1 %to 14;
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
	if subjid='02-03' and s_1^=. and s_2^=. and s_3^=. then output _base_4;
		else output _base_5;
run;

data _base_4;
	set _base_4 (rename=(s_1=ss_1 s_2=ss_2 s_3=ss_3));
 keep subjid ss_1 ss_2 ss_3;
run;

data _base_6;
	merge _base_4 _base_5;
	by subjid;
	if s_1=. then s_1=ss_1;
	if s_2=. then s_2=ss_2;
	if s_3=. then s_3=ss_3;

	drop  ss_1 ss_2 ss_3 visit2;
run;

proc sort data=_base_1; by subjid lbdtn; run;

data _base_1;
	set _base_1;
	by subjid lbdtn;
	if last.subjid;
run;


data _base_7;
	merge _base_1 _base_6;
	by subjid;
run;

%macro nonmiss(var=);
	%do i=1 %to 14;
	&var&&i=coalesce(&var&&i,s&var&&i);
	%end;
%mend;

data _base;
	set _base_7;

	%nonmiss(var=_);

	drop s_:;
run;


data _max _min _last;
    set hema1;
        by subjid;
    length max1 - max100 min1 - min100 last1 - last100 8; /*100 is an arbitary number which is larger than # of hema test*/
    retain max1 - max100 min1 - min100 last1 - last100 ;
    array maxl{100} max1-max100;
    array minl{100} min1-min100;
    array last{100} last1-last100;
    array hema{*} _:;
    if first.subjid then
        do i = 1 to dim(hema);
           maxl[i] = hema[i]; 
           minl[i] = hema[i];
           last[i] = hema[i];
        end;
    else 
        do i = 1 to dim(hema);
           if nmiss(maxl[i],hema[i])<2 then maxl[i] = max(maxl[i], hema[i]);
           if nmiss(minl[i],hema[i])<2 then minl[i] = min(minl[i], hema[i]);
/*            maxl[i] = max(maxl[i], hema[i]);*/
/*            minl[i] = min(minl[i], hema[i]);*/
            last[i] = coalesce(hema[i], last[i]);
        end;
    if last.subjid then 
        do;
            do i = 1 to dim(hema);
                hema[i] = last[i];
            end;
            output _last;
            do i = 1 to dim(hema);
                hema[i] = maxl[i];
            end;
            output _max;
            do i = 1 to dim(hema);
                hema[i] = minl[i];
            end;
            output _min;
        end;
   
    keep subjid  _:;
run;

data hema2;
    set _base (in = a)
        _min  (in = b)
        _max  (in = c)
        _last (in = d)
    ;
    by subjid;
    attrib 
        type    length = $40   label = 'Laboratory#(Hematology)'
    ;
    if a then type = 'Baseline';
    else if b then type = 'Lowest';
    else if c then type = 'Highest';
    else if d then type = 'Last';

run;


data _mockup0;
    set hema2;
        by subjid;
    if first.subjid then output;
    keep subjid;
run;

data _mockup;
    set _mockup0;
    attrib 
        type    length = $40   label = 'Laboratory#(Hematology)'
    ;
    type = 'Baseline'; __ord = 1; output;
    type = 'Lowest';   __ord = 2; output;
    type = 'Highest';  __ord = 3; output;
    type = 'Last';     __ord = 4; output;
run;

%sort(indata = _mockup, sortkey = subjid type);
%sort(indata = hema2,   sortkey = subjid type);

data hema3;
    merge hema2 _mockup;
        by subjid type;
    format _numeric_ na.;
run;

%sort(indata = hema3, sortkey = subjid __ord);

data pdata.hema1;
    retain subjid type _10 _9 _2 _7 _8;
    set hema3;
    keep subjid type _10 _9 _2 _7 _8;
	format _all_;
run;

data pdata.hema2;
    retain subjid type _6 _1 _5 _4 _12 _13 _11 _14 _3;
    set hema3;
    keep subjid type _6 _1 _5 _4 _12 _13 _11 _14 _3;
	format _all_;
/*	format _11 10.1;*/
run;
