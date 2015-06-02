/*********************************************************************
 Program Nmae: BP.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/15
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/
%include "_setup.sas";


data bp;
    length xbdtc $40 ;
    set source.bp;
    %subject;
	%visit2;
    if xbmetho ^='' then xbmeth6_ = strip(xbmetho);else xbmeth6_=strip(put(xbmeth6,checkyes.));
    xbdtc=put(xbdt,yymmdd10.);
     

    __edc_treenodeid=edc_treenodeid ;
    __edc_entrydate=edc_entrydate;
	format  xbmeth1 xbmeth2 xbmeth3 xbmeth5 xbmeth6 xblabyn1 xblabyn2 xblabyn3 xbperfa xbperfb xblbnd checked.;
    keep subject visit2 xblbnd xbperfa xbperfb xblbcd cellular lymcyinv xblinf xbmeth1 xbmeth2 xbmeth3 
         xbmeth5 xbmeth6 xblabyn1 xblabyn2 xblabyn3 xblaban xblabrea xbdtc xblinf __edc_treenodeid  __edc_entrydate;
run;

data bp1;
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

proc sort data=bp1;by subject xbdtc visit2;run;

data out.bp1(label="Bone Marrow Aspirate and Biopsy");
    retain __edc_treenodeid __edc_entrydate subject visit2 xblbnd xbdtc xbperfb xbperfa xblbcd cellular lymcyinv xblinf xbmeth1 
           xbmeth2 xbmeth3 xbmeth5 xbmeth6 ;
    attrib

    xbmeth1     label="H and E@:Method of Assessment"
    xbmeth2     label="IHC@:Method of Assessment"
    xbmeth3     label="Flow Cytometry@:Method of Assessment"
    xbmeth5     label="Cytogenetics@:Method of Assessment"
    xbmeth6     label="Other,Specify@:Method of Assessment"
    xbdtc       label="Date"
    xbperfa     label="Aspirate@:Sample(s) Obtained"
    xbperfb     label="Biopsy@:Sample(s) Obtained"
    xblbnd     label="Not Done"
    ;
    set bp1;
    keep __edc_treenodeid __edc_entrydate subject visit2 xblbnd xbdtc xbperfb xbperfa xblbcd cellular lymcyinv xblinf xbmeth1 
           xbmeth2 xbmeth3 xbmeth5 xbmeth6 ;
    label xblinf = 'If Positive, Percent Infiltration (%)';
    label xblbcd = 'Lab Code';
run;


data out.bp2(label="Bone Marrow Aspirate and Biopsy (Continued)");
    retain __edc_treenodeid __edc_entrydate subject visit2 xbdtc  xblabyn2 xblabyn1 xblabyn3 xblaban xblabrea;
    attrib

    xblabyn1    label="Aspirate@:Were additional samples collected and sent to central lab"
    xblabyn2    label="Biopsy@:Were additional samples collected and sent to central lab"
    xblabyn3    label="Not Done@:Were additional samples collected and sent to central lab"
    xbdtc      label="Date"
    ;
    set bp1;
    keep __edc_treenodeid __edc_entrydate subject visit2 xbdtc xblabyn1 xblabyn2 xblabyn3 xblaban xblabrea;
    label xblaban = 'If additional biopsy or aspirate collected, please provide Accession Number';
    label xblabrea = 'If Not Done, specify reason';
run;

