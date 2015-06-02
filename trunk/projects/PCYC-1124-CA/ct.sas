/*********************************************************************
 Program Nmae: CT.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data ct0;
    set source.ct;
    keep edc_treenodeid edc_entrydate subject yr visit cycle ctres1 ctres2 ctres3 ctmri1
        ctmri2 ctmri3 ctmrioth ctespl cteliv seq ctdt ;
    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;
    rename yr = __yr;
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

    %subject;
    
    ** Assessment Date;
    length ctdtc $20;
    label ctdtc = 'Assessment Date';
    %ndt2cdt(ndt=ctdt, cdt=ctdtc);
    rc = h.find();
    %concatdy(ctdtc);
    drop ctdt rc;

    ** VISIT;
    %visit;
    
    ** CT/MRI Assessments;
    format ctres1 $checked.;
    format ctres2 $checked.;
    format ctres3 $checked.;

    ** If MRI, Specify Reason;
    format ctmri1 $checked.;
    format ctmri2 $checked.;
    drop ctmri3;

run;

proc sort data = ct1; by subject ctdtc visit2; run;

data pdata.ct(label='Imaging by CT/MRI');
    retain __edc_treenodeid __edc_entrydate subject visit2 ctdtc ctres1 ctres2 ctres3 ctmri1 ctmri2 ctmrioth ctespl cteliv;
    keep __edc_treenodeid __edc_entrydate subject visit2 ctdtc ctres1 ctres2 ctres3 ctmri1 ctmri2 ctmrioth ctespl cteliv;
    set ct1;
run;
