

%macro formatDate(date);
    length __Day $10 __Month $10 __Year $10;
    * - > Get Year/Month/Day Component ;
    __Year=strip(scan(&date,1,'-'));
    __Month=strip(scan(&date,2,'-'));
    __Day=strip(scan(&date,3,'-'));
    if __Year='****' then __Year='';
    if __Month='**' then __Month='';
    if __Day='**' then __Day='';

    &date=catx('-',__Year,__Month,__Day);
%mend formatDate;

%macro char(var=,newvar=);
        &newvar=ifc(&var^=.,strip(put(&var,best.)),'');
%mend char;

%macro ageint(RFSTDTC=, BRTHDTC=, AGE=);
   __RFSTDTC = &RFSTDTC;
   __BRTHDTC = &BRTHDTC;
   if __RFSTDTC ^= '' and length(compress(__RFSTDTC)) = 10 and __BRTHDTC ^= '' and 
    length(compress(__BRTHDTC)) = 10 then
      &AGE._=int((input(substr(__RFSTDTC, 1, 10), yymmdd10.) - input(substr(__BRTHDTC, 1, 10), yymmdd10.) + 1)/365.25);
    %char(var=&AGE._,newvar=&AGE);
%mend ageint; 

%macro IsNumeric(InStr=, Result=);
    length __InStr $200;
   &Result = 1;
   __PeriodCount = 0;

   __InStr = trim(left(&InStr));
   if substr(__InStr, 1, 1) in ('-', '+') then __InStr = trim(left(substr(__InStr, 2)));

   do __n = 1 to length(__InStr);
      if substr(__InStr, __n, 1) not in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.') then
         &Result = 0;
      if substr(__InStr, __n, 1) = '.' then __PeriodCount = __PeriodCount + 1;
   end;
   if __PeriodCount > 1 then &Result = 0;
%mend IsNumeric;



/*
    low : normal range low limit (numeric)
    high: normal range high limit (numeric)
    result: lab result (character)
*/
%macro lablowhigh(low=, high=, result=);
    __result = 0;
    if &low =. then __low = -1E99;
    else __low = &low;
    if &high =. then __high = 1E99;
    else __high = &high;
    %IsNumeric(InStr = &result, Result = __result);
    if __result = 1 then do;
        __numrslt = input(&result, best.);
        if __numrslt < __low then &result = "&escapechar{style [foreground=&belowcolor]"||strip(&result)||'}';
        else if __numrslt > __high then &result = "&escapechar{style [foreground=&abovecolor]"||strip(&result)||'}';
    end;
%mend lablowhigh;




** Ken Cao on 2014/11/12: Add color code note for lab data **;
%macro addnote(indata=, labrslt=, labcat=, lowcolor=blue, highcolor=red);

data __low;
    set &indata(keep=subid &labrslt);
    where compress(&labrslt) contains "&escapechar{style[foreground=&lowcolor]";
    keep subid;
run;

data __high;
    set &indata(keep=subid &labrslt);
    where compress(&labrslt) contains "&escapechar{style[foreground=&highcolor]";
    keep subid;
run;

proc sort data = __low nodupkey; by subid; run;
proc sort data = __high nodupkey; by subid; run;

data &indata;
    length subid $40;
    if _n_ = 1 then do;
        declare hash h1 (dataset: '__low');
        rc1 = h1.defineKey('subid');
        rc1 = h1.defineDone();
        declare hash h2 (dataset: '__high');
        rc2 = h2.defineKey('subid');
        rc2 = h2.defineDone();
        call missing(subid);
    end;
    set &indata;
    rc1 = h1.find();
    rc2 = h2.find();

    length __label __high __low $256;
    __low = "&escapechar{style [foreground=blue fontsize=8pt]&lowcolor: Lower than lower limit}";
    __high = "&escapechar{style [foreground=red fontsize=8pt]&highcolor: Higher than higher limit}";

    if rc1 = 0 and rc2 = 0 then __label = "&labcat ( "||strip(__low)||', '||strip(__high)||')';
    else if rc1 = 0 then __label = "&labcat ( "||strip(__low)||')';
    else if rc2 = 0 then __label = "&labcat ( "||strip(__high)||')';
    else __label = "&labcat";

    drop rc1 rc2 __low __high;
run;

%mend addnote;
