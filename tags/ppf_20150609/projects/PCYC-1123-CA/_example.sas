/*********************************************************************
 Program Nmae: _example.sas
  @Author: Ken Cao
  @Initial Date: 2015/04/08
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/


%include '_setup.sas';

data ae;

    ** copy below code to declare and create a hash object. DO NOT COPY THIS LINE **;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    **********************************************************************************; 
    set source.ae;

    ** copy below line to trim subject id value;
    %subject;

    ** remember to define length of --DTC as 20 (at least);
    length aestdtc $20 aeendtc $20;

    ** call macro CONCATDATE to concat year/month/day;
    %concatDate(year=aestyy, month=aestmm, day=aestdd, outdate=aestdtc);
    %concatDate(year=aeenyy, month=aeenmm, day=aeendd, outdate=aeendtc);

    ** call hash find method;
    rc = h.find();

    ** call concatDY macro to derive --DY and concatenate it into ---DTC;
    %concatDY(aestdtc);
    %concatDY(aeendtc);


    keep subject aest: aeen:;
run;



data cm;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set source.cm;
    %subject;
    length cmstdtc $20 cmendtc $20;
    %concatDate(year=cmstyy, month=cmstmm, day=cmstdd, outdate=cmstdtc);
    %concatDate(year=cmenyy, month=cmenmm, day=cmendd, outdate=cmendtc);
    rc = h.find();
    %concatDY(cmstdtc);
    %concatDY(cmendtc);
    keep subject cmst: cmen:;
run;


data lb;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set source.lb;
    %subject;
    length lbdtc $20;
    %ndt2cdt(ndt=lbdt, cdt=lbdtc);
    rc = h.find();
    %concatDY(lbdtc);
    keep subject lbdt:;
run;
