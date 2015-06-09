/********************************************************************************
 Program Nmae: LBTB.sas
  @Author: Yan Zhang
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

data lbtb0;
    length visit $29 lbtbty lbtbor lbtbme $200;
    keep __edc_treenodeid __edc_entrydate subject visit lbtbacc lbtbdtc lbtbty lbtbor lbtbim lbtbme;
    set source.lbtb(rename = (EDC_TreeNodeID = __edc_treenodeid EDC_EntryDate = __edc_entrydate));

    %subject;
    length lbtbdtc $20;
    label lbtbdtc = 'Sample Date';
    %ndt2cdt(ndt=lbtbdt, cdt=lbtbdtc);
    
    if lbtbtyo ^='' then lbtbty = strip(lbtbty)||": "||strip(lbtbtyo);
    if lbtboro ^='' then lbtbor = strip(lbtbor)||": "||strip(lbtboro);
    if lbtbmeo ^='' then lbtbme = strip(lbtbme)||": "||strip(lbtbmeo);

/*    cycle = cycle;*/
/*  seq = seq;** in case that cycle is added in the furture.;*/
/*  %visit;*/
run;

data lbtb1;
    length subject $13 rfstdtc $10;
    length sex $6 __age 8;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        declare hash h2 (dataset:'pdata.dm');
        rc2 = h2.defineKey('subject');
        rc2 = h2.defineData('sex','__age');
        rc2 = h2.defineDone();
        call missing(subject, rfstdtc, sex, __age);
    end;
    set lbtb0;
    rc = h.find();
    rc2 = h2.find();
    %concatdy(lbtbdtc);
    drop rc rc2;
run;

proc sort data = lbtb1; by subject lbtbdtc visit; run;

data out.lbtb(label = 'Tumor Biopsy for Eligibility');
    retain __edc_treenodeid __edc_entrydate subject visit lbtbdtc lbtbacc lbtbty lbtbor lbtbim lbtbme;
    keep __edc_treenodeid __edc_entrydate subject lbtbdtc visit lbtbacc lbtbty lbtbor lbtbim lbtbme;
    set lbtb1;

    label visit = 'Visit';
    label lbtbty = 'Type of sample submitted';
    label lbtbor = 'Origin of tumor sample';
    label lbtbim = 'Immunohistochemistry (IHC) / DLBCL Subtype Result';

run;
