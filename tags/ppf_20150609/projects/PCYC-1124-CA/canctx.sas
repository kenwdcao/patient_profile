/*********************************************************************
 Program Nmae: CANCTX.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/02/25
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 
 Ken Cao on 2015/02/27: Add --DY to TXSTDTC and TXENDTC.

*********************************************************************/
%include "_setup.sas";

data canctx;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set source.canctx;
    if rxyn='';
    %subject;
    length txstdtc txendtc $20 ;
    %concatDate(year=txstyy, month=txstmm, day=txstdd, outdate=txstdtc);
    %concatDate(year=txenyy, month=txenmm, day=txendd, outdate=txendtc);
    ** Ken Cao on 2015/02/27: Add --DY to TXSTDTC and TXENDTC.;
    rc = h.find();
    %concatDY(txstdtc);
    %concatDY(txendtc);
    txongo=strip(put(txongo,$checked.));
    __edc_treenodeid=edc_treenodeid ;
    __edc_entrydate=edc_entrydate;
    keep __edc_treenodeid __edc_entrydate subject ctnum txtype txterm txttyp txtypeo txint txproc  txstdtc txendtc txongo;
run;

proc sort data=canctx;by subject txstdtc txendtc;run;

data out.canctx (label="Subsequent Antineoplastic Therapy");
    retain __edc_treenodeid __edc_entrydate subject ctnum txtype txterm txttyp txtypeo txint txproc  txstdtc txendtc txongo;
    attrib
    ctnum       label="Record Number"
    txongo      label="Ongoing"
    txstdtc     label="Start Date"
    txendtc     label="End Date"
    txterm      label='Subsequent Antineoplastic Therapy'
    txttyp      label='If Stem Cell Transplant, select Type'
    txtypeo     label='If Other, describe'
    ;
    set canctx;
    keep __edc_treenodeid __edc_entrydate subject ctnum txtype txterm txttyp txtypeo txint txproc  txstdtc txendtc txongo;
run;
