/*********************************************************************
 Program Nmae: CT.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/13
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';


data ct0;
    set source.ct;
    %subject;
     %visit2;
    keep edc_treenodeid edc_entrydate subject CTND visit2  ctres1 ctres2 ctres3 ctmri1
        ctmri2 ctmri3 ctmrioth ctespl cteliv seq ctdt ;
    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;
    format  ctnd ctres1 ctres2 ctres3 ctmri1 ctmri2 checked.;
run;

data ct1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set ct0;

    
    
    ** Assessment Date;
    length ctdtc $20;
    label ctdtc = 'Assessment Date';
    %ndt2cdt(ndt=ctdt, cdt=ctdtc);
    rc = h.find();
    %concatdy(ctdtc);
    drop ctdt rc;

    ** If MRI, Specify Reason;
    drop ctmri3;
run;

proc sort data = ct1; by subject ctdtc  visit2; run;

data pdata.ct(label='Imaging by CT/MRI');
    retain __edc_treenodeid __edc_entrydate subject visit2 ctnd ctdtc  ctres1 ctres2 ctres3 ctmri1 ctmri2 ctmrioth ctespl cteliv;
    keep __edc_treenodeid __edc_entrydate subject visit2 ctnd ctdtc  ctres1 ctres2 ctres3 ctmri1 ctmri2 ctmrioth ctespl cteliv;
    set ct1;
 label CTRES1 = 'CT with Contrast@:CT/MRI Assessments'
       CTRES2 = 'CT without Contrast@:CT/MRI Assessments'
       CTRES3 = 'MRI@:CT/MRI Assessments'
       ctmri1 = 'CT contrast contraindicated@:If MRI, Specify Reason'
       ctmri2 = 'Lesions not well visualized by CT@:If MRI, Specify Reason'
       ctmrioth= 'Other Specify@:If MRI, Specify Reason'
       ctnd = 'Not Done';
       ;
run;
