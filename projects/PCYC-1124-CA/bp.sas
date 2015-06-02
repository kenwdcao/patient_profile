/*********************************************************************
 Program Nmae: BP.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/02/25
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/
%include "_setup.sas";

data bp;
    length xbdtc $40 xbmeth6 $200;
    set source.bp;
    %subject;
    xbperfa=strip(put(xbperfa,$checked.));
    xbperfb=strip(put(xbperfb,$checked.));
    xbmeth1=strip(put(xbmeth1,$checked.));
    xbmeth2=strip(put(xbmeth2,$checked.));
    xbmeth3=strip(put(xbmeth3,$checked.));
    xbmeth5=strip(put(xbmeth5,$checked.));
    if xbmetho ^='' then xbmeth6 = strip(xbmetho);else xbmeth6=strip(put(xbmeth6,$checked.));
    xblabyn1=strip(put(xblabyn1,$checked.));
    xblabyn2=strip(put(xblabyn2,$checked.));
    xblabyn3=strip(put(xblabyn3,$checked.));
    xbdtc=put(bpdt,yymmdd10.);
    __edc_treenodeid=edc_treenodeid ;
    __edc_entrydate=edc_entrydate;
    keep subject visit xbperfa xbperfb xblbcd cellular lymcyinv xblinf xbmeth1 xbmeth2 xbmeth3 
         xbmeth5 xbmeth6 xblabyn1 xblabyn2 xblabyn3 xblaban xblabrea xbdtc yr cycle xblinf __edc_treenodeid  __edc_entrydate;
run;

data bp2;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set bp;
    rc = h.find();
    %concatdy(xbdtc);

    label xbdtc = 'Sample Date';
run;

proc sort data=bp;by subject xbdtc;run;

data out.bp1(label="Bone Marrow Aspirate and Biopsy");
    retain __edc_treenodeid __edc_entrydate subject visit xbdtc xbperfa xbperfb xblbcd cellular lymcyinv xblinf xbmeth1 
           xbmeth2 xbmeth3 xbmeth5 xbmeth6 ;
    attrib
    visit       label = 'Visit'
    xbmeth1     label="H and E"
    xbmeth2     label="IHC"
    xbmeth3     label="Flow Cytometry"
    xbmeth5     label="Cytogenetics"
    xbmeth6     label="Other,Specify"
    xbdtc       label="Date"
    xbperfa     label="Biopsy"
    xbperfb     label="Aspirate"
    ;
    set bp2;
    keep __edc_treenodeid __edc_entrydate subject visit xbdtc xbperfa xbperfb xblbcd cellular lymcyinv xblinf xbmeth1 
           xbmeth2 xbmeth3 xbmeth5 xbmeth6;
    label xblinf = 'If Positive, Percent Infiltration (%)';
    label xblbcd = 'Lab Code';
run;


data out.bp2(label="Bone Marrow Aspirate and Biopsy (Continued)");
    retain __edc_treenodeid __edc_entrydate subject visit xbdtc xblabyn1 xblabyn2 xblabyn3 xblaban xblabrea;
    attrib
    visit       label = 'Visit'
    xblabyn1    label="Biopsy"
    xblabyn2    label="Aspirate"
    xblabyn3    label="Not Done"
    xbdtc       label="Date"
    ;
    set bp2;
    keep __edc_treenodeid __edc_entrydate subject visit xbdtc xblabyn1 xblabyn2 xblabyn3 xblaban xblabrea;
    label xblaban = 'If additional biopsy or aspirate collected, please provide Accession Number';
    label xblabrea = 'If Not Done, specify reason';
run;

