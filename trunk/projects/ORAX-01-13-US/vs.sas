/*
    Program Name: VS.sas
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Intial Date: 2013/12/03

*/

%include '_setup.sas';

data vs0;
    set source.vt_signs source.vt_signs2;
    attrib
        vsdtc        length = $20
        visit        length = $40
;
    %subjid;
    vsdtc = strip(scan(event_start_date, 1, ' '));
    *vsdt  = input(vsdtc, mmddyy10.);
    /* Ken Cao on 2014/10/24: Informat of VSDTC was changed to yyyy-mm-dd */
    vsdt = input(vsdtc, yymmdd10.);
    visit = study_event_oid;
   
    keep subjid vsdtc vsdt visit systolic diastolic heartrt resp temp weight;
run;

%sort(indata = vs0, sortkey = subjid vsdt);

data _base_1 _base_2;
    set vs0;
    if index(visit, 'BASELINE') > 0 then output _base_1;
        else if index(visit, 'SCREENING') > 0 then output _base_2;
/*    where visit contains 'BASELINE' or visit contains 'SCREENING';*/

    keep subjid systolic diastolic heartrt resp temp weight visit;
run;

data _base_3;
    set _base_2; 
    rename WEIGHT=WEIGHT_s HEARTRT=HEARTRT_s TEMP=TEMP_s SYSTOLIC=SYSTOLIC_s DIASTOLIC=DIASTOLIC_s RESP=RESP_s;

run;

data _base_4;
    merge _base_1 _base_3;
    by subjid;
run;

data _base;
    set _base_4;
    weight=coalesce(WEIGHT,WEIGHT_s);
    HEARTRT=coalesce(HEARTRT,HEARTRT_s);
    TEMP=coalesce(TEMP,TEMP_s);
    SYSTOLIC=coalesce(SYSTOLIC,SYSTOLIC_s);
    DIASTOLIC=coalesce(DIASTOLIC,DIASTOLIC_s);
    RESP=coalesce(RESP,RESP_s);

    drop WEIGHT_s HEARTRT_s TEMP_s SYSTOLIC_s DIASTOLIC_s RESP_s;
run;

data _max _min _last;
    set vs0;
        by subjid;
    length max1 - max100 min1 - min100 last1 - last100 8; /*100 is an arbitary number which is larger than # of hema test*/
    retain max1 - max100 min1 - min100 last1 - last100 ;
    array maxl{100} max1-max100;
    array minl{100} min1-min100;
    array last{100} last1-last100;
    array vital{*} systolic diastolic heartrt resp temp weight;
    if first.subjid then
        do i = 1 to dim(vital);
           maxl[i] = vital[i]; 
           minl[i] = vital[i];
           last[i] = vital[i];
        end;
    else 
        do i = 1 to dim(vital);
            maxl[i] = max(maxl[i], vital[i]);
            minl[i] = min(minl[i], vital[i]);
            last[i] = coalesce(vital[i], last[i]);
        end;
    if last.subjid then 
        do;
            do i = 1 to dim(vital);
                vital[i] = last[i];
            end;
            output _last;
            do i = 1 to dim(vital);
                vital[i] = maxl[i];
            end;
            output _max;
            do i = 1 to dim(vital);
                vital[i] = minl[i];
            end;
            output _min;
        end;
    keep subjid systolic diastolic heartrt resp temp weight;
run;

data vs1;
    set _base(in = a)
        _min(in = b)
        _max(in = c)
        _last(in = d)
    ;
    attrib
        type      length = $40        label = 'Vital Sign'
    ;
    if a then type = 'Baseline';
    else if b then type = 'Lowest';
    else if c then type = 'Highest';
    else if d then type = 'Last';
run;

%sort(indata = vs1, sortkey = subjid);

data _mockup0;
    set vs1;
        by subjid;
    if first.subjid then output;
    keep subjid;
run;

data _mockup;
    set _mockup0;
    type = 'Baseline'; __ord = 1; output;
    type = 'Lowest';   __ord = 2; output;
    type = 'Highest';  __ord = 3; output;
    type = 'Last';     __ord = 4; output;
run;

%sort(indata = _mockup, sortkey = subjid type);
%sort(indata = vs1, sortkey = subjid type);

data vs2;
    merge vs1 _mockup;
        by subjid type;

    attrib
        systolic_     length = $20       label = 'Systolic Blood#Pressure (mmHg)'
        diastolic_    length = $20       label = 'Diastolic Blood#Pressure (mmHg)'
        heartrt_      length = $20       label = 'Pulse#(beats/min)'
        resp_         length = $20       label = 'Respirations#(breaths/min)'
        temp_         length = $20       label = 'Temperature#(C)'
        weight_       length = $20       label = 'Weight#(lb)'
    ;
    array vsnum{*} systolic diastolic heartrt resp temp weight;
    array vschar{*} systolic_ diastolic_ heartrt_ resp_ temp_ weight_;

    do i = 1 to dim(vsnum);
        vschar[i] = ifc(vsnum[i] > ., put(vsnum[i], best.), 'N/A');
    end;

    keep subjid type systolic_ diastolic_ heartrt_ resp_ temp_ weight_  __ord;;
run;

%sort(indata = vs2, sortKey = subjid __ord);

data pdata.vs;
    retain subjid type systolic_ diastolic_ heartrt_ resp_ temp_ weight_;
    set vs2;
    keep subjid type systolic_ diastolic_ heartrt_ resp_ temp_ weight_;
run;
