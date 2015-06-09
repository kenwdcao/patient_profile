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
    lborres1 = coalescec(lborres, lbstresc);

    **************modify on 2014-06-04**************;
    /*Ken Cao on 2014/10/24: to exclude null values*/
    if index(lborres,"<")=0 and lborres > ' ' then do;
        lborres2   = input(coalescec(lborres, lbstresc), best.); end;
    else if index(lborres,"<")>0 and lborres > ' ' then do;
        lborres2=input(substr(strip(lborres),2),best.); end;

    ** Ken Cao on 2014/12/15: Display zero before deceimal point;
    if lborres2 > . then lborres1 = strip(put(lborres2, best.));


/*    lbtest2    = strip(scan(lbtest_label, 2, '-'));\*/
    lbtest2    = substr(lbtest_label, 13);

    lbdtc      = lbdt;
    *lbdtn      = input(lbdt, mmddyy10.);
    /* Ken Cao on 2014/10/24: Informat of LBDT was changed to yyyy-mm-dd*/
    lbdtn      = input(lbdt, yymmdd10.);
    visit2     = visit_label;
    keep subjid lbtest lbtest2 lborres2 lbdtc lbdtn visit2 lborres1;
run;

%sort(indata = chem0, sortkey = subjid lbdtn lbdtc visit2 lbtest lbtest2, nodupkey = Y);

proc transpose data = chem0 out = chem1_1(drop = _name_);
    by subjid lbdtn lbdtc visit2;
    id lbtest;
    idlabel lbtest2;
    var lborres1;
run;

proc transpose data = chem0 out = chem1_2(drop = _name_);
    by subjid lbdtn lbdtc visit2;
    id lbtest;
    idlabel lbtest2;
    var lborres2;
run;

**********************Base***************************;
%macro numtochar(var=);
    %do i=15 %to 36;
    rename &var&&i=c&var&&i;
/*  drop &var&&i;*/
    %end;
%mend;

data chem1_1_01;
    set chem1_1;
%numtochar(var=_);
run;

proc sort data=chem1_2; by subjid visit2 lbdtc; run;
proc sort data=chem1_1_01; by subjid visit2 lbdtc; run;

data chem1_1_02;
    merge chem1_2 chem1_1_01;
    by subjid visit2 lbdtc;
run;


***************base****************;
data _base_1 _base_2;
    set chem1_1_01;
    if  strip(upcase(visit2)) in ('BASELINE') then output _base_1;
        else if strip(upcase(visit2)) in ('SCREENING') then output _base_2;
    keep subjid  VISIT2 lbdtc lbdtn c:;
run;

/*%macro screenvar(var=);*/
/*  %do i=15 %to 36;*/
/*  s&var&&i=&var&&i;*/
/*  %end;*/
/*%mend;*/
    
data _base_3;
    set _base_2;
%numtochar(var=c_);

run;
********************************;
proc sort data=_base_3; by subjid descending lbdtn; run;

data _base_3_01;
    set _base_3;
    by subjid descending lbdtn;
    length sc_15 - sc_100 $200;
    retain sc_15 - sc_100 ;
    array new{*} sc_:;

    array char{*} cc_:;

    if first.subjid then
        do i = 1 to dim(char);
           new[i] = char[i]; 
        end; 

    else 
        do i = 1 to dim(char);
            if new[i]='' then new[i]=char[i];
        end;

    if last.subjid;

    keep  subjid lbdtn lbdtc visit2 sc_15-sc_36;

run;

data _base_7;
    merge _base_1  _base_3_01;
    by subjid;
run;

%macro nonmiss(var=);
    %do i=15 %to 36;
    &var&&i=coalescec(&var&&i,s&var&&i);
    %end;
%mend;

data _base;
    set _base_7;

    %nonmiss(var=c_);

    drop sc_:;
run;

%sort(indata = chem1_1_02, sortkey = subjid lbdtn lbdtc visit2 );

data _maxc _minc _lastc;
    set chem1_1_02;
        by subjid;
    length max1 - max100 min1 - min100 last1 - last100 8 maxc1 - maxc100 minc1 - minc100 lastc1 - lastc100 $20; /*100 is an arbitary number which is larger than # of hema test*/
    retain max1 - max100 min1 - min100 last1 - last100 maxc1 - maxc100 minc1 - minc100 lastc1 - lastc100;
    array max{100} max1-max100;
    array min{100} min1-min100;
    array last{100} last1-last100;
    array maxc{100} maxc1-maxc100;
    array minc{100} minc1-minc100;
    array lastc{100} lastc1-lastc100;

    array chem{*} _:;
    array chemc{*} c:;

    if first.subjid then
        do i = 1 to dim(chem);
           max[i] = chem[i]; 
           min[i] = chem[i];
           last[i] = chem[i];
           maxc[i] = chemc[i]; 
           minc[i] = chemc[i];
           lastc[i] = chemc[i];

        end;
    else 
        do i = 1 to dim(chem);
           if nmiss(max[i],chem[i])<2 then do; 
                if max[i]< chem[i] then do; max[i]= chem[i]; maxc[i]= chemc[i];end; 
                else if max[i]>= chem[i] then do;max[i]= max[i]; maxc[i]= maxc[i];end; end;

           if nmiss(min[i],chem[i])=0 then do; 
                        if min[i]> chem[i] then do; min[i]= chem[i]; minc[i]= chemc[i];end; 
                else if min[i]= chem[i] and index(chemc[i],"<")>0 then do; min[i]= chem[i]; minc[i]= chemc[i];end;
                else if min[i]= chem[i] and index(chemc[i],"<")=0 then do; min[i]= min[i]; minc[i]= minc[i];end;
                else if min[i]< chem[i]  then do; min[i]= min[i]; minc[i]= minc[i];end; end;

           if min[i]=. and chem[i]^=. then do; 
                    min[i]= chem[i]; minc[i]= chemc[i];end; 

           if min[i]^=. and chem[i]=. then do; 
                min[i]= min[i]; minc[i]= minc[i];end; 


            last[i] = coalesce(chem[i], last[i]);
            lastc[i] = coalescec(chemc[i], lastc[i]);

        end;
    if last.subjid then 
        do;
            do i = 1 to dim(chem);
                chem[i] = last[i];
                chemc[i] = lastc[i];

            end;
            output _lastc;
            do i = 1 to dim(chem);
                chem[i] = max[i];
                chemc[i] = maxc[i];

            end;
            output _maxc;
            do i = 1 to dim(chem);
                chem[i] = min[i];
                chemc[i] = minc[i];

            end;
            output _minc;
        end;
   
    keep subjid  _: c:;
run;


data chem2;
    set _base (in = a)
        _minc  (in = b)
        _maxc  (in = c)
        _lastc (in = d)
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
    retain subjid type c_21 c_20 c_30 c_19 c_28 c_17 c_26 c_24;
    set chem3;
    keep subjid type c_21 c_20 c_30 c_19 c_28 c_17 c_26 c_24;
    format _all_;

run;

data pdata.chem2;
    retain subjid type c_34 c_33 c_16 c_15 c_23 c_35 c_25;
    set chem3;
    keep subjid type c_34 c_33 c_16 c_15 c_23 c_35 c_25;
    format _all_;

run;

data pdata.chem3;
    retain subjid type c_27 c_18 c_22 c_27 c_29 c_31 c_32 c_36;
    set chem3;
    keep subjid type c_27 c_18 c_22 c_27 c_29 c_31 c_32 c_36;
    format _all_;
run;
