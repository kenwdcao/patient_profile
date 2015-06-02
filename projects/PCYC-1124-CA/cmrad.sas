/*********************************************************************
 Program Nmae: CMRAD.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/02/25
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/02/27: 1) Fix RDENDTC;
                        2) Combine all RDSITExx together.


*********************************************************************/
%include "_setup.sas";

data cmrad;
    length rdstdtc rdendtc $10 rdsite12 $200;
    set source.cmrad;

    %subject;
    %concatDate(year=rdstyy, month=rdstmm, day=rdstdd, outdate=rdstdtc);
    %concatDate(year=rdenyy, month=rdenmm, day=rdendd, outdate=rdendtc);

    rdsite01=strip(put(rdsite01,$checked.));
    rdsite02=strip(put(rdsite02,$checked.));
    rdsite03=strip(put(rdsite03,$checked.));
    rdsite04=strip(put(rdsite04,$checked.));
    rdsite05=strip(put(rdsite05,$checked.));
    rdsite06=strip(put(rdsite06,$checked.));
    rdsite07=strip(put(rdsite07,$checked.));
    rdsite08=strip(put(rdsite08,$checked.));
    rdsite09=strip(put(rdsite09,$checked.));
    rdsite10=strip(put(rdsite10,$checked.));
    rdsite11=strip(put(rdsite11,$checked.));
    rdsite13=strip(put(rdsite13,$checked.));
    rdsite14=strip(put(rdsite14,$checked.));
    rdsite15=strip(put(rdsite15,$checked.));

    ** Ken Cao on 2015/02/27: Combine all RDSITExx together;
    __st = length("Prior Radiation") + 2;
    length __site $60;
    length _rdsite $500;
    label _rdsite = 'All Fields Previously Treated with Radiation';
    array rdsite{*} rdsite:;
    do i = 1 to dim(rdsite);
        if rdsite[i] = ' ' then continue;
        else if vname(rdsite[i])='RDSITE12' then continue; ** Skip "Other";

        __site = substr(vlabel(rdsite[i]), __st);

        ** Ken Cao on 2015/02/27: Deal with raw data label truncation; 
        if strip(scan(__site, -1, '-')) = 'R' then __site = strip(__site)||'ight';
        else if strip(scan(__site, -1, '-')) = 'L' then __site = strip(__site)||'eft';
        

        ** Other Specify;
        if vname(rdsite[i])='RDSITEO' then __site = 'Other: '||rdsiteo;

        
        _rdsite = ifc(_rdsite>' ', strip(_rdsite)||'; '||__site, __site);
    end;

/*    if rdsiteo^='' then rdsite12=rdsiteo;else rdsite12=strip(put(rdsite12_,$checked.));*/
    if rdgyu^='' then rdgy="Unknown"; else rdgy=rdgy;



    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;

run;

proc sort data=cmrad;by subject rdstdtc rdendtc;run;

data out.cmrad (label="Prior DLBCL Radiation");
    retain __edc_treenodeid __edc_entrydate subject _rdsite rdstdtc rdendtc rdgy ;
    attrib
    rdstdtc     label="Start Date"
    rdendtc     label="End Date"
    rdgy        label="Total Dose (Gy)"
    ;
    set cmrad;
    keep __edc_treenodeid __edc_entrydate subject _rdsite rdstdtc rdendtc rdgy ;
run;

/*
data out.cmrad1 (label="Prior DLBCL Radiation");
    retain __edc_treenodeid __edc_entrydate subject rdstdtc rdendtc rdgy rdsite01 rdsite02 rdsite03 rdsite04 rdsite05 
        rdsite06;
    attrib
    rdstdtc     label="Start Date"
    rdendtc     label="End Date"
    rdgy        label="Total Dose (Gy)"
    rdsite01    label="Axilla - Right"
    rdsite02    label="Axilla - Left"
    rdsite03    label="Groin - Right"
    rdsite04    label="Groin - Left"
    rdsite05    label="Neck Supraclavicular - Right"
    rdsite06    label="Neck Supraclavicular - Left"
    ;
    set cmrad;
    keep __edc_treenodeid __edc_entrydate subject rdstdtc rdendtc rdgy rdsite01 rdsite02 rdsite03 rdsite04 rdsite05 
        rdsite06;
run;

data out.cmrad2 (label="Prior DLBCL Radiation (Continued)");
    retain __edc_treenodeid __edc_entrydate subject rdsite07 rdsite08 rdsite09 rdsite10 rdsite11 rdsite13 rdsite14 rdsite15
        rdsite12;
    attrib
    rdsite07    label="Neck Cervical - Right"
    rdsite08    label="Neck Cervical - Left"
    rdsite09    label="Neck Preauricular - Right"
    rdsite10    label="Neck Preauricular - Left"
    rdsite11    label="Mediastinum"
    rdsite13    label="Mantle"
    rdsite14    label="Para-aortic"
    rdsite15    label="Inverted Y"
    rdsite12    label="Other, Specify"
    ;
    set cmrad;
    keep __edc_treenodeid __edc_entrydate subject rdsite07 rdsite08 rdsite09 rdsite10 rdsite11 rdsite13 rdsite14 rdsite15
        rdsite12;
run;
*/
