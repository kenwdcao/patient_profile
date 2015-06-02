%include '_setup.sas';

data hema0;
    set source.lab_resultsresults;
    where upcase(scan(lbtest_label, 1, '-')) = 'HEMATOLOGY';
    attrib
        lborres2    length = 8
        lbtest2     length = $200
        lbdtc       length = $20
        visit2      length = $200
        lborres1     length=$200
    ;
    %subjid;
    lborres1 = coalescec(lborres, lbstresc);
    lborres2 = input(lborres1, best.);
    
    ** Ken Cao on 2014/12/15: Display zero before deceimal point;
    lborres1 = strip(put(lborres2, best.));

    lbtest2  = strip(scan(lbtest_label, 2, '-'));
    lbdtc    = lbdt;
    *lbdtn    = input(lbdt, mmddyy10.);
    /* Ken Cao on 2014/10/24: Informat of LBDT was changed to yyyy-mm-dd */
    lbdtn    = input(lbdt, yymmdd10.);
    visit2   = visit_label;
    keep subjid lbtest lbtest2 lborres2 lbdtc lbdtn visit2 lborres1;
run;
***********modify on 2014-06-04***************;
proc sort data=hema0 dupout=a nodupkey; by _all_; run;


%sort(indata = hema0, sortkey = subjid lbdtn lbdtc visit2 lbtest lbtest2, nodupkey=Y /* Ken Cao on 2014/08/28: remove duplicates */);

proc transpose data = hema0 out = hema1_1(drop = _name_);
    by subjid lbdtn lbdtc visit2;
    id lbtest;
    idlabel lbtest2;
    var lborres1;
run;

proc transpose data = hema0 out = hema1_2(drop = _name_);
    by subjid lbdtn lbdtc visit2;
    id lbtest;
    idlabel lbtest2;
    var lborres2;
run;


%macro numtochar(var=);
    %do i=1 %to 14;
    rename &var&&i=c&var&&i;
    %end;
%mend;

data hema1_1_01;
    set hema1_1;
%numtochar(var=_);
run;

proc sort data=hema1_2; by subjid visit2 lbdtc; run;
proc sort data=hema1_1_01; by subjid visit2 lbdtc; run;

data hema1_1_02;
    merge hema1_2 hema1_1_01;
    by subjid visit2 lbdtc;
run;


***************base****************;
data _base_1 _base_2;
    set hema1_1_01;
    if  strip(upcase(visit2)) in ('BASELINE') then output _base_1;
        else if strip(upcase(visit2)) in ('SCREENING') then output _base_2;
    keep subjid  VISIT2 lbdtc lbdtn c:;
run;

proc sort data=_base_1; by subjid lbdtn; run;

data _base_1;
    set _base_1;
    by subjid lbdtn;
    if last.subjid;
run;

%macro screenvar(var=);
    %do i=1 %to 14;
    s&var&&i=&var&&i;
    %end;
%mend;
    
data _base_3;
    set _base_2;
/* %screenvar(var=c_);*/
 %numtochar(var=c_);

run;

proc sort data=_base_3; by subjid descending lbdtn; run;

data _base_3_01;
    set _base_3;
    by subjid descending lbdtn;
    length sc_1 - sc_100 $200;
    retain sc_1 - sc_100 ;
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

    keep  subjid lbdtn lbdtc visit2 sc_1-sc_14;

run;



data _base_7;
    merge _base_1  _base_3_01;
    by subjid;
run;

%macro nonmiss(var=);
    %do i=1 %to 14;
    &var&&i=coalescec(&var&&i,s&var&&i);
    %end;
%mend;

data _base;
    set _base_7;

    %nonmiss(var=c_);

    drop sc_:;
run;


%sort(indata = hema1_1_02, sortkey = subjid lbdtn lbdtc visit2 );

data _maxc _minc _lastc;
    set hema1_1_02;
        by subjid;
    length max1 - max100 min1 - min100 last1 - last100 8 maxc1 - maxc100 minc1 - minc100 lastc1 - lastc100 $20; /*100 is an arbitary number which is larger than # of hema test*/
    retain max1 - max100 min1 - min100 last1 - last100 maxc1 - maxc100 minc1 - minc100 lastc1 - lastc100;
    array max{100} max1-max100;
    array min{100} min1-min100;
    array last{100} last1-last100;
    array maxc{100} maxc1-maxc100;
    array minc{100} minc1-minc100;
    array lastc{100} lastc1-lastc100;

    array hema{*} _:;
    array hemac{*} c:;

    if first.subjid then
        do i = 1 to dim(hema);
           max[i] = hema[i]; 
           min[i] = hema[i];
           last[i] = hema[i];
           maxc[i] = hemac[i]; 
           minc[i] = hemac[i];
           lastc[i] = hemac[i];

        end;
    else 
        do i = 1 to dim(hema);
           if nmiss(max[i],hema[i])<2 then do; 
                if max[i]< hema[i] then do; max[i]= hema[i]; maxc[i]= hemac[i];end; 
                else if max[i]>= hema[i] then do;max[i]= max[i]; maxc[i]= maxc[i];end; end;

           if nmiss(min[i],hema[i])=0 then do; 
                        if min[i]> hema[i] then do; min[i]= hema[i]; minc[i]= hemac[i];end; 
                else if min[i]<= hema[i] then do; min[i]= min[i]; minc[i]= minc[i];end; end;

           if min[i]=. and hema[i]^=. then do; 
                    min[i]= hema[i]; minc[i]= hemac[i];end; 

           if min[i]^=. and hema[i]=. then do; 
                min[i]= min[i]; minc[i]= minc[i];end; 


            last[i] = coalesce(hema[i], last[i]);
            lastc[i] = coalescec(hemac[i], lastc[i]);

        end;
    if last.subjid then 
        do;
            do i = 1 to dim(hema);
                hema[i] = last[i];
                hemac[i] = lastc[i];

            end;
            output _lastc;
            do i = 1 to dim(hema);
                hema[i] = max[i];
                hemac[i] = maxc[i];

            end;
            output _maxc;
            do i = 1 to dim(hema);
                hema[i] = min[i];
                hemac[i] = minc[i];

            end;
            output _minc;
        end;
   
    keep subjid  _: c:;
run;


data hema2;
    set _base (in = a)
        _minc  (in = b)
        _maxc  (in = c)
        _lastc (in = d)
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
    retain subjid type c_10 c_9 c_2 c_7 c_8;
    set hema3;
    keep subjid type c_10 c_9 c_2 c_7 c_8;
    format _all_;
run;

data pdata.hema2;
    retain subjid type c_6 c_1 c_5 c_4 c_12 c_13 c_11 c_14 c_3;
    set hema3;
    keep subjid type c_6 c_1 c_5 c_4 c_12 c_13 c_11 c_14 c_3;
    format _all_;
run;
