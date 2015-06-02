/********************************************************************************
 Program Nmae: ML.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

data ml0;
   length subject $13;
    set source.ml_coded(rename =(EDC_TreeNodeID = __EDC_TreeNodeID  EDC_EntryDate = __EDC_EntryDate seq=__seq));
    %subject;	
run;

data ml;
    length  subject $13 __rfstdtc $10 mldtc  none none_ $20 mlfind_ $200;
   if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
    set ml0;
   rc = h.find();

	**label**;
 label 
 mldtc='Date of Diagnosis'
 manum = 'Record Number'
 MLSTAGET='Primary Tumor#(T)@:STAGING'
 MLSTAGEN='Regional Lymph Nodes#(N)@:STAGING'
 MLSTAGEM='Distant Metastasis#(M)@:STAGING'
 MLSTAGEO='Other Staging@:STAGING'

 none='None@:Treatment'
 MLSURGSP = 'Surgery@:Treatment'
 MLCHEMSP = 'Chemotherapy@:Treatment'
 MLHORMSP = 'Hormonal therapy@:Treatment'
 MLRADISP = 'Radiation therapy@:Treatment'
 MLOTHSP = 'Other@:Treatment'
 MLOUT='Subject Outcome / Current Status'
 MLINTENT='Check box if treatment was administered with curative intent'
MLANTITX='Is it likely this additional malignancy is related to any anti-cancer treatment the subject has received?'
MLTHERA ='Anti-Cancer Treatments Specify'
MLCYTO='Anti-Cancer Treatments Cytogenetics'

 none_ = 'None@:Subject''s cancer risk '
 MLCANCRS = 'Family history of cancer@:Subject''s cancer risk '
 MLOVRWTS = 'History of being >30 lbs overweight@:Subject''s cancer risk '
MLRADITS = 'Radiation therapy of the body before age 30@:Subject''s cancer risk '
MLALCOHS = 'Alcohol ingestion@:Subject''s cancer risk '
 MLSMOKES = 'Smoking@:Subject''s cancer risk '
 MLOTHRS = 'Other@:Subject''s cancer risk ';
 **END**;

  none=ifc(mltxnone^=' ','Yes',' ');
  none_=ifc(mlsrnone^=' ','Yes',' ');

      label aenum='Corresponding Adverse Events Number';
    aenum=catx(", ",strip(vvaluex('MLAENO01')),strip(vvaluex('MLAENO02')),strip(vvaluex('MLAENO03')));

	    label mhnum='Corresponding Medical History Number';
    mhnum=catx(", ",strip(vvaluex('MLMHNO01')),strip(vvaluex('MLMHNO02')),strip(vvaluex('MLMHNO03')));

   %concatDate(year=mlyy, month=mlmm, day=mldd, outdate=mldtc);
    %concatDY(mldtc);

	if mlfindsp^ = ' ' then mlfind_ = 'Yes, '||mlfindsp;
    else mlfind_ = mlfind;
    label mlfind_ = 'Biopsy/Pathology Findings';

	if mlthernr > ' ' then mlthera = 'Not Reported';
    if mlcytonr > ' ' then mlcyto = 'Not Reported';
run;

proc sort data=ml; by subject mldtc  mldiag;run; 

data pdata.ml1(label='Other Malignancy');
   retain    __edc_treenodeid  __edc_entrydate subject  __seq manum mldiag mldtc 
   mlfind_ mlstaget mlstagen mlstagem mlstageo;
    keep   __edc_treenodeid  __edc_entrydate subject   __seq manum mldiag mldtc 
   mlfind_ mlstaget mlstagen mlstagem mlstageo;
	set ml;
run;

data pdata.ml2(label='Other malignancy (continued)');
   retain    __edc_treenodeid  __edc_entrydate subject   __seq manum 
   none mlsurgsp mlchemsp mlhormsp mlradisp mlothsp mlout mlintent mlantitx mlthera mlcyto;
    keep   __edc_treenodeid  __edc_entrydate subject   __seq manum 
   none mlsurgsp mlchemsp mlhormsp mlradisp mlothsp mlout mlintent mlantitx mlthera mlcyto;
	set ml;
run;

data pdata.ml3(label='Other malignancy (continued)');
   retain    __edc_treenodeid  __edc_entrydate subject   __seq manum  
 none_  mlcancrs mlovrwts mlradits mlalcohs mlsmokes mlothrs aenum mhnum;
    keep   __edc_treenodeid  __edc_entrydate subject   __seq manum  
 none_  mlcancrs mlovrwts mlradits mlalcohs mlsmokes mlothrs aenum mhnum;
	set ml;
run;





