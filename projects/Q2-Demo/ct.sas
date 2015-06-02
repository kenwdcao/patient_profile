/*********************************************************************
 Program Nmae: CT.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/02/02
 
 __________________________________________________________________
 Modification History:

BFF on 2015/02/05: Modify rules of ctres3, ctres3a, ctres3p, ctres3o
Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
Ken Cao on 2015/03/05: Concatenate --DY to CTDTC.

*********************************************************************/
%include "_setup.sas";

data ct;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    length ctdtc $20;
    set source.ct;
    %subject;
    *if ctdt ^=. then ctdtc=put(ctdt,yymmdd10.);
    %ndt2cdt(ndt=ctdt, cdt=ctdtc);
    rc = h.find();
    %concatDY(ctdtc);
    drop rc;
    if crseq^=. then visit=strip(visit)||" "||strip(put(crseq,best.));
    else if pdseq^=. then visit=strip(visit)||" "||strip(put(pdseq,best.));
    else if unsseq^=. then visit=strip(visit)||" "||strip(put(unsseq,best.));
    else visit=visit;
    ctnd=strip(put(ctnd,$checked.));

    ctres1=strip(put(ctres1,$checked.));
    ctres1n=strip(put(ctres1n,$checked.));
    ctres1c=strip(put(ctres1c,$checked.));
    ctres1a=strip(put(ctres1a,$checked.));
    ctres1p=strip(put(ctres1p,$checked.));
    ctres1o=strip(put(ctres1o,$checked.));

    ctres2=strip(put(ctres2,$checked.));
    ctres2n=strip(put(ctres2n,$checked.));
    ctres2c=strip(put(ctres2c,$checked.));
    ctres2o=strip(put(ctres2o,$checked.));

    ctres3=strip(put(ctres3,$checked.));
    ctres3a=strip(put(ctres3a,$checked.));
    ctres3p=strip(put(ctres3p,$checked.));
    ctres3o=strip(put(ctres3o,$checked.));

    ctmri1=strip(put(ctmri1,$checked.));
    ctmri2=strip(put(ctmri2,$checked.));
    ctmri3=strip(put(ctmri3,$checked.));
    __edc_treenodeid=edc_treenodeid ;
    rename EDC_EntryDate = __EDC_EntryDate;
    keep subject visit ctdtc ctres1 ctres1n ctres1c ctres1a ctres1p ctres1o ctres1s ctres2 
         ctres2n ctres2c ctres2o ctres2s ctres3 ctres3a ctres3p ctres3o ctres3s ctmri1 ctmri2 
         ctmri3 ctmrioth ctespl cteliv __edc_treenodeid EDC_EntryDate; 
run;

proc sort data=ct;by subject ctdtc;run;

data pdata.ct1(label="Imaging by CT/MRI");
    retain __edc_treenodeid __EDC_EntryDate subject visit ctdtc ctres1 ctres1n ctres1c ctres1a ctres1p ctres1s ctres2 
         ctres2n ctres2c ctres2s;
    attrib
    ctdtc       label="Date" 
    ctres1      label="CT with contrast"
    ctres1n     label="Neck"
    ctres1c     label="Chest"
    ctres1a     label="Abdomen"
    ctres1p     label="Pelvis"
    ctres1s     label="Other Disease Site(s), specify"
    ctres2      label="CT without contrast"
    ctres2n     label="Neck"
    ctres2c     label="Chest"
    ctres2s     label="Other Disease Site(s), specify"
    visit           label = 'Visit'
    ;
    set ct;
    keep __edc_treenodeid __EDC_EntryDate subject visit ctdtc ctres1 ctres1n ctres1c ctres1a ctres1p ctres1s ctres2 
         ctres2n ctres2c ctres2s;
run;

data pdata.ct2(label="Imaging by CT/MRI (Continued)");
    retain __edc_treenodeid  __EDC_EntryDate subject visit ctdtc ctres3 ctres3a ctres3p ctres3s ctmri1 ctmri2 ctmrioth ctespl cteliv;
    attrib
    ctdtc       label="Date" 
    ctres3      label="MRI"
    ctres3a     label="Abdomen"
    ctres3p     label="Pelvis"
    ctres3s     label="Other Disease Site(s), specify"
    ctmri1      label="CT contrast contraindicated"
    ctmri2      label="Lesions not well visualized by CT"
    ctmrioth    label="Other, Specify"
    ctespl      label="Enlarged Spleen?"
    cteliv      label="Enlarged Liver?"
    visit           label = 'Visit'
    ;
    set ct;
    keep __edc_treenodeid __EDC_EntryDate subject visit ctdtc ctres3 ctres3a ctres3p ctres3s ctmri1 ctmri2 ctmrioth ctespl cteliv;
run;
