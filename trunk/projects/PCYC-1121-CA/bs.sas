/*********************************************************************
 Program Nmae: BS.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/05: Concatenate --DY to BSDTC.

*********************************************************************/
%include "_setup.sas";

data bs;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    length bsdtc $20;
    set source.bs;
    %subject;
    *if bsdt^=. then bsdtc=put(bsdt,yymmdd10.);
    %ndt2cdt(ndt=bsdt, cdt=bsdtc)
    rc = h.find();
    %concatDY(bsdtc)
    drop rc;
    bsnd=strip(put(bsnd,$checked.));
    if crseq^=. then visit=strip(visit)||" "||strip(put(crseq,best.));
    else if unsseq^=. then visit=strip(visit)||" "||strip(put(unsseq,best.));
    else if pdseq^=. then visit=strip(visit)||" "||strip(put(pdseq,best.));
    else visit=visit;
    __edc_treenodeid =edc_treenodeid ;
    rename EDC_EntryDate = __EDC_EntryDate;
    keep __edc_treenodeid EDC_EntryDate  subject bsnd bsyn bswl bswlsig bsfev bssweat bsoccur bsdtc visit;
run;

proc sort data=bs;by subject bsdtc;run;

data pdata.bs(label="B-Symptoms");
    retain __edc_treenodeid __EDC_EntryDate subject visit bsdtc bsnd bsyn bswl bswlsig bsfev bssweat bsoccur;
    attrib
    bsnd    label="Not Done"
    bsdtc   label="Assessment Date"
    visit label = 'Visit'
    ;
    set bs;
    keep __edc_treenodeid __EDC_EntryDate subject bsnd bsyn bswl bswlsig bsfev bssweat bsoccur bsdtc visit;
run;
