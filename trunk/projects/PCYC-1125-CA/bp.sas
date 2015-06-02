/*********************************************************************
 Program Nmae: BP.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/03/13
 
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/03/16: Add --DY.

*********************************************************************/

%include '_setup.sas';


** read from source datasets;
data bp;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    length bmdtc $20;
    set source.bp(rename=(bmdtc=bmdtc_));
    %subject;
    length bmdtc $20;
    bmdtc=bmdtc_;
    rc = h.find();
    %concatDY(bmdtc);
    __id=id;
    keep __id subject bmdtc lbcode cellular lymph lymcyinv bmmhe bmmihc bmmmfc bmmmcyto bmmmo bmmeosp bmtasp bmtbp bmtnd;
run; 

proc sort data=bp;by subject bmdtc;

data pdata.bp(label="Bone Marrow Aspirate and Biopsy");
    retain __id subject bmdtc lbcode cellular lymph lymcyinv bmmhe bmmihc bmmmfc bmmmcyto bmmmo bmmeosp bmtasp bmtbp bmtnd;
    attrib
    bmdtc           label="Sample Date";
    set bp;
    keep __id subject bmdtc lbcode cellular lymph lymcyinv bmmhe bmmihc bmmmfc bmmmcyto bmmmo bmmeosp bmtasp bmtbp bmtnd;

    label bmmhe = 'H and E';
    label bmmihc = 'IHC';
    label bmmmfc = 'Flow Cytometry';
    label bmmmcyto = 'Cytogenetics';
    label bmmmo = 'Other';
    label bmmeosp = 'Other(Specify)';

    rename bmmmo = __bmmmo;

    label bmtasp = 'Aspirate';
    label bmtbp = 'Biopsy';
    label bmtnd = 'Not Done';
run;
