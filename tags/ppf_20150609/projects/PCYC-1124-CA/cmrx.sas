/*********************************************************************
 Program Nmae: CMRX.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/27
 
 New CMRX.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/28: 1) Combine "How was progression determined?" 

*********************************************************************/
%include "_setup.sas";

data cmrx0;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.cmrx(keep = edc_treenodeid subject visit rxcat rxrgnumn rxtryn rxtrtyp rxresp
                           rxprdd rxprmm rxpryy rxprdtuk rxprdtna pdct pdpe pdbmbiop pdlnbiop 
                           pdunk pdsinc pdnles pdnless pdoth pdoths rxgrid rxtrt rxtrtinv rxcyc 
                           rxstdd rxstmm rxstyy rxendd rxenmm rxenyy rxyn rdyn psyn seq rxrgnum
                           rxtrdt edc_entrydate);
    %subject;
    
    rc = h.find();
    drop rc;


    ** Regimen associated with a transplant;
    length _rxtryn $255;
    label _rxtryn = 'Was this regimen associated with a transplant';
    _rxtryn = rxtryn;
    if rxtrtyp > ' ' then _rxtryn = strip(_rxtryn)||', '||rxtrtyp;
    drop rxtryn rxtrtyp;


    ** Date of Progression;
    length rxprdtc $20;
    label rxprdtc = 'Date of Progression';
    %concatDate(year=rxpryy, month=rxprmm, day=rxprdd, outdate=rxprdtc);
    %concatDY(rxprdtc);
    drop rxpryy rxprmm rxprdd;
    if rxprdtuk > ' ' then rxprdtc = strip(rxprdtc)||' '||'Unknown';
    if rxprdtna > ' ' then rxprdtc = strip(rxprdtc)||' '||'Unknown';
    rxprdtc = strip(rxprdtc);
    drop rxprdtuk rxprdtna;


    ** Date of Transplant;
    length rxtrdtc $20;
    label rxtrdtc = 'Date of Transplant';
    %ndt2cdt(ndt=rxtrdt, cdt=rxtrdtc, fmt=yymmdd10.);
    %concatDY(rxtrdtc);
    drop rxtrdt;


    ** New lesion(s), specify location(s);
    length pdnles_ $500;
    label pdnles_ = 'New lesion(s), specify location(s)';
    if pdnless > ' ' then pdnles_ = pdnless;
    if pdnles_ = ' ' and pdnles > ' ' then do;
        pdnles_ = 'New Lesion';
        put "WARN" "ING: New Lesion was checked, but location was not specified";
    end;


    ** Other (specify);
    length pdoth_ $255;
    label pdoth_ = 'Other (specify)';
    if pdoths > ' ' then pdoth_ = pdoths;
    if pdoth_ = ' ' and pdoth > ' ' then do;
        pdoth_ = 'Other';
        put "WARN" "ING: Other was checked, but no details specified";
    end;


    ** Prior DLBCL Treatment Start Date and End Date;
    length rxstdtc rxendtc $20;
    label rxstdtc = 'Start Date';
    label rxendtc = 'End Date';
    %concatDate(year=rxstyy, month=rxstmm, day=rxstdd, outdate=rxstdtc);
    %concatDate(year=rxenyy, month=rxenmm, day=rxendd, outdate=rxendtc);
    %concatDY(rxstdtc);
    %concatDY(rxendtc);
    drop rxstyy rxstmm rxstdd rxenyy rxenmm rxendd;


    ** Ken Cao on 2015/02/28: Combine "How was progression determined?" ;
    length _pddetrm $255;
    label _pddetrm = 'Progression determined by';
    __st = length("Progression Determined by") + 2;
    array pddetrm{*} pdct pdpe pdbmbiop pdlnbiop pdunk;
    do i = 1 to dim(pddetrm);
        if pddetrm[i] = ' ' then continue;
        _pddetrm = ifc(_pddetrm>' ', strip(_pddetrm)||', '||substr(vlabel(pddetrm[i]), __st), substr(vlabel(pddetrm[i]), __st));
    end;
    drop i __st pdct pdpe pdbmbiop pdlnbiop pdunk;
    
    
    format rxrgnumn $checked.;
    format pdct $checked.;
    format pdpe $checked.;
    format pdbmbiop $checked.;
    format pdlnbiop $checked.;
    format pdunk $checked.;
    format pdsinc $checked.;
    

    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;
run;

/* One record per subject part */
data cmrx1;
    set cmrx0;
    keep __edc_treenodeid __edc_entrydate subject visit rxyn rdyn psyn;
    where rxcat = ' ';
run;


proc sort data=cmrx0 nodupkey 
out=cmrx2(keep = __edc_treenodeid __edc_entrydate subject visit rxcat rxrgnum rxrgnumn _rxtryn rxtrdtc
                  rxresp rxprdtc _pddetrm pdsinc pdnles_ pdoth_);
    by subject rxrgnum;
    where rxcat >  ' ';
run;

proc sort data=cmrx0  
out=cmrx3(keep = __edc_treenodeid __edc_entrydate subject visit rxcat rxrgnum rxgrid rxtrt rxtrtinv rxcyc 
                  rxstdtc rxendtc);
    by subject rxrgnum rxgrid;
    where rxcat >  ' ' and rxtrt > ' ';
run;


data pdata.cmrx1(label='Prior DLBCL Therapy Prompt');
    retain __edc_treenodeid __edc_entrydate subject visit rxyn rdyn psyn;
    set cmrx1;
    keep __edc_treenodeid __edc_entrydate subject visit rxyn rdyn psyn;
    rename visit = __visit;

    label rxyn = 'Does the subject have any prior DLBCL related chemo therapy, immunotherapy, and/or stem cell transplant to report?';
    label rdyn = 'Does the subject have any prior DLBCL related radiation to report?';
    label psyn = 'Does the subject have any prior DLBCL surgery to report?';

run;

data pdata.cmrx2(label='Prior DLBCL Treatment');
    retain __edc_treenodeid __edc_entrydate subject visit rxcat rxrgnum rxrgnumn _rxtryn rxtrdtc 
           rxresp rxprdtc _pddetrm pdsinc pdnles_ pdoth_;
    keep __edc_treenodeid __edc_entrydate subject visit rxcat rxrgnum rxrgnumn _rxtryn rxtrdtc 
           rxresp rxprdtc _pddetrm pdsinc pdnles_ pdoth_;
    set cmrx2;
    rename rxcat = __rxcat;
    rename visit = __visit;
    label PDSINC = 'Increase in size of existing lesion(s)';
run;

data pdata.cmrx3(label='Prior DLBCL Treatment (Continued)');
    retain __edc_treenodeid __edc_entrydate subject visit rxcat rxrgnum rxgrid rxtrt rxtrtinv rxcyc  rxstdtc rxendtc;
    keep __edc_treenodeid __edc_entrydate subject visit rxcat rxrgnum rxgrid rxtrt rxtrtinv rxcyc  rxstdtc rxendtc;
    set cmrx3;
    rename rxcat = __rxcat;
    rename visit = __visit;

    label rxgrid = 'Agent #';
run;
