/*********************************************************************
 Program Nmae: BP.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

Ken Cao on 2015/02/05: Split BP into two datasets.
Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
Ken Cao on 2015/03/05: Concatenate --DY to XBDTC.

*********************************************************************/
%include "_setup.sas";

data bp;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    length xbdtc $20 xbmeth6 $200;
    set source.bp;
    %subject;
    xbmeth1=strip(put(xbmeth1,$checked.));
    xbmeth2=strip(put(xbmeth2,$checked.));
    xbmeth3=strip(put(xbmeth3,$checked.));
    xbmeth5=strip(put(xbmeth5,$checked.));
    if xbmetho ^='' then xbmeth6 = strip(xbmetho);else xbmeth6=strip(put(xbmeth6,$checked.));
    xblabyn1=strip(put(xblabyn1,$checked.));
    xblabyn2=strip(put(xblabyn2,$checked.));
    xblabyn3=strip(put(xblabyn3,$checked.));
    *xbdtc=put(xbdt,yymmdd10.);
    %ndt2cdt(ndt=xbdt, cdt=xbdtc);
    rc = h.find();
    %concatDY(xbdtc);
    drop rc;
    if crseq^=. then visit=strip(visit)||" "||strip(put(crseq,best.));
    else if unsseq^=. then visit=strip(visit)||" "||strip(put(unsseq,best.));
    else visit=visit;
    __edc_treenodeid=edc_treenodeid ;
    rename EDC_EntryDate = __EDC_EntryDate;
    keep subject visit xblbnd xbovcel xboccur xblinf xbmeth1 xbmeth2 xbmeth3
         xbmeth5 xbmeth6 xblabyn1 xblabyn2 xblabyn3 xblabrea xbdtc xblbcd __edc_treenodeid EDC_EntryDate;
run;

proc sort data=bp;by subject xbdtc;run;
/*
data out.bp(label="Bone Marrow Aspirate and Biopsy");
    retain subject  visit xbdtc xblbnd xblbcd xbovcel xboccur xblinf xbmeth1 xbmeth2 xbmeth3
         xbmeth5 xbmeth6 xblabyn1 xblabyn2 xblabyn3 xblabrea;
    attrib
    visit           label = 'Visit'
    xbmeth1     label="H and E"
    xbmeth2     label="IHC"
    xbmeth3     label="Flow Cytometry"
    xbmeth5     label="Cytogenetics"
    xbmeth6     label="Other,Specify"
    xblabyn1    label="Aspirate"
    xblabyn2    label="Biopsy"
    xblabyn3    label="Not Done"
    xbdtc       label="Date"
    ;
    set bp;
    keep subject visit xblbnd xbovcel xboccur xblinf xbmeth1 xbmeth2 xbmeth3
         xbmeth5 xbmeth6 xblabyn1 xblabyn2 xblabyn3 xblabrea xbdtc xblbcd;
run;
*/



data out.bp1(label="Bone Marrow Aspirate and Biopsy");
    retain __edc_treenodeid __EDC_EntryDate subject  visit xbdtc xblbnd xblbcd xbovcel xboccur xblinf xbmeth1 xbmeth2 xbmeth3 xbmeth5 xbmeth6 ;
    attrib
    visit           label = 'Visit'
    xbmeth1     label="H and E"
    xbmeth2     label="IHC"
    xbmeth3     label="Flow Cytometry"
    xbmeth5     label="Cytogenetics"
    xbmeth6     label="Other,Specify"
    xbdtc       label="Date"
    ;
    set bp;
    keep __edc_treenodeid __EDC_EntryDate subject visit xblbnd xbovcel xboccur xblinf xbmeth1 xbmeth2 xbmeth3 xbmeth5 xbmeth6   xbdtc xblbcd;
run;


data out.bp2(label="Bone Marrow Aspirate and Biopsy (Continued)");
    retain __edc_treenodeid __EDC_EntryDate subject visit xbdtc xblbnd xblbcd xblabyn1 xblabyn2 xblabyn3 xblabrea;
    attrib
    visit           label = 'Visit'
    xblabyn1    label="Aspirate"
    xblabyn2    label="Biopsy"
    xblabyn3    label="Not Done"
    xbdtc       label="Date"
    ;
    set bp;
    keep __edc_treenodeid __EDC_EntryDate subject visit xblbnd xblabyn1 xblabyn2 xblabyn3 xblabrea xbdtc xblbcd;
run;
