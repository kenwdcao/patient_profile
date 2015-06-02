/*********************************************************************
 Program Nmae: CM.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
BFF on 2015/03/04: Re-assigned DOSE length.
Ken Cao on 2015/03/04: Display NULL and UNK for CMSTDTC / CMENDTC.
Ken Cao on 2015/03/05: Concatenate --DY to CMSTDTC and CMENDTC.

*********************************************************************/
%include "_setup.sas";

data cm;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    length cmstdtc cmendtc  $20 dose $20;
    set source.cm;
    if cmyn='';
    %subject;
/*    %concatDate(year=cmstyy, month=cmstmm, day=cmstdd, outdate=cmstdtc);*/
/*    %concatDate(year=cmenyy, month=cmenmm, day=cmendd, outdate=cmendtc);*/
    %concatDateV2(year=cmstyy, month=cmstmm, day=cmstdd, outdate=cmstdtc);
    %concatDateV2(year=cmenyy, month=cmenmm, day=cmendd, outdate=cmendtc);
    
    rc = h.find();
    %concatDY(cmstdtc);
    %concatDY(cmendtc);

    if cmroute='Other' and cmroutes^='' then route='Other'||': '||strip(cmroutes);
    else route=cmroute;

    cmongo=strip(put(cmongo,$checked.));

    if cmdose='' and cmdoseuk^='' then dose='Unk';
    else dose=cmdose;

    if cmdosu='Other' and cmdosus^='' then unit='Other'||': '||strip(cmdosus);
    else unit=cmdosu;

    if cmdosfrq='Other' and cmdosfrs^='' then freq='Other'||': '||strip(cmdosfrs);
    else freq=cmdosfrq;
    __edc_treenodeid=edc_treenodeid ;
    rename EDC_EntryDate = __EDC_EntryDate;
    keep __edc_treenodeid EDC_EntryDate subject cmcat cmtrt  cmindc dose unit freq route cmstdtc cmendtc cmongo;
run;

proc sort data=cm;by subject cmstdtc cmendtc cmtrt;run;

data pdata.cm (label="Concomitant Medications");
    retain __edc_treenodeid __EDC_EntryDate subject cmtrt cmindc dose unit freq route cmstdtc cmendtc cmongo;
    attrib
    dose    label="Dose"
    unit    label="Unit"
    freq    label="Frequency"
    route   label="Route"
    cmstdtc label="Start Date"
    cmendtc label="End Date"
    ;
    set cm;
    keep __edc_treenodeid __EDC_EntryDate subject cmtrt  cmindc dose unit freq route cmstdtc cmendtc cmongo;
run;
