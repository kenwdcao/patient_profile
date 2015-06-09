/********************************************************************************
 Program Nmae: TB.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/10
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data tb;
     length tbcondtc tbdtc tbwithdtc $20  subject tbp1 tbp2 tbnd_ $13 rfstdtc $10 type tbo $100;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
 
    set source.tb (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate EDC_FormLabel=__EDC_FormLabel));
    %subject;
  
    label tbcondtc = 'Date of Consent to Optional Tumor Tissue Substudy Collection';
    %ndt2cdt(ndt=tbcondt, cdt=tbcondtc);
    rc = h.find();
    %concatDY(tbcondtc);

    ***value for checked**;
    tbp1 = put(tbphase1, checked.);
    label tbp1='Subject Consent to Pre-Treatment';

    tbp2 = put(tbphase2, checked.);
    label tbp2='Subject Consent to Post-Progression';

    tbnd_ = put(tbnd, checked.);
    label tbnd_='Not Done';

    *****pre**;
    label tbdtc = 'Sample Date';
    %ndt2cdt(ndt=tbdt, cdt=tbdtc);
    rc = h.find();
    %concatDY(tbdtc);

    label TBmc = 'Collection Time';
    %ntime2ctime(ntime=TBtm, ctime=tbmc);

    label type='Type of sample submitted';
    type=ifc(tbtypeo^='', cat('Other: ', strip(tbtypeo)),strip(tbtype));
 
    label tbo='Origin of tumor sample';
    tbo=ifc(tborgso^='', cat('Other: ', strip(tborgso)),strip(tborgs));

    **withdraw***;
   label tbwithdtc = 'Date of withdrawal of Consent';
    %ndt2cdt(ndt=tbwithdt, cdt=tbwithdtc);
    rc = h.find();
    %concatDY(tbwithdtc);
   
     label tbwith='Subject withdrew consent for optional tumor tissue substudy collection';
     label tbwithf='Subject withdrew consent for future sample testing';
run;

proc sort data=tb; by subject tbcondtc;run;

data pdata.tb1(label='Optional Tumor Tissue Substudy Consent');
    retain __EDC_TreeNodeID __EDC_EntryDate subject  tbyn  tbp1 tbp2 tbcondtc;
    keep __EDC_TreeNodeID __EDC_EntryDate subject  tbyn  tbp1 tbp2 tbcondtc;
    set tb;
    where __EDC_FormLabel='Optional Tumor Tissue Substudy Consent';
    
    label tbyn = 'Does subject consent to the Optional Tumor Tissue Substudy Collection?';
    label tbp1 = 'Pre-Treatment@:Which Optional Tumor Tissue collection did the subject consent to?';
    label tbp2 = 'Post-Progression@:Which Optional Tumor Tissue collection did the subject consent to?';
    label tbcondtc = 'Date of Consent to Optional Tumor Tissue Substudy Collection';

run;

data pdata.tb2(label='Optional Tumor Tissue Sample (Pre-Treatment)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject  tbnd_ tbdtc tbrefid   TBTYPE TBTYPEO TBORGS TBORGSO;
    keep __EDC_TreeNodeID __EDC_EntryDate subject  tbnd_ tbdtc  tbrefid TBTYPE TBTYPEO TBORGS TBORGSO ;
    set tb;
    where __EDC_FormLabel='Optional Tissue Sample (Pre-Treatment)';
run;

data pdata.tb3(label='Optional Tumor Tissue Sample (Post-Progression)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject  tbnd_ tbdtc tbmc tbrefid  TBTYPE TBTYPEO TBORGS TBORGSO;
    keep __EDC_TreeNodeID __EDC_EntryDate subject  tbnd_ tbdtc tbmc tbrefid  TBTYPE TBTYPEO TBORGS TBORGSO;
    set tb;
    where __EDC_FormLabel='Optional Tumor Tissue Sample (Post-Progression)';
run;

data pdata.tb4(label='Optional Tumor Tssue Substudy Consent Withdrawal');
    retain __EDC_TreeNodeID __EDC_EntryDate subject  tbwithdtc  tbwith  tbwithf;
    keep __EDC_TreeNodeID __EDC_EntryDate subject  tbwithdtc  tbwith  tbwithf  __EDC_FormLabel;
    set tb;
    where __EDC_FormLabel not in ('Optional Tumor Tissue Substudy Consent', 'Optional Tissue Sample (Pre-Treatment)',
    'Optional Tumor Tissue Sample (Post-Progression)'); 
run;

