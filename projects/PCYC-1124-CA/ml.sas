/********************************************************************************
 Program Name: ML.sas
  @Author: Taodong Chen
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/28: Split ML into two datasets.

********************************************************************************/
%include '_setup.sas';

data ml;
length mldtc $20 trt1-trt5 can1-can6 treatmnt $200; 
    set source.ml (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
    seq = .;
    %concatDate(year=mlyy, month=mlmm, day=mldd, outdate=mldtc);
    if mlsurg= 'Checked' then trt1 = 'Surgery';
    if mlsurgsp ^='' then trt1=strip(trt1)||', '||strip(mlsurgsp);

    if mlchem= 'Checked' then trt2 = 'Chemotherapy';
    if mlchemsp ^='' then trt2=strip(trt2)||', '||strip(mlchemsp);

    if mlhorm= 'Checked' then trt3 = 'Hormonal Therapy';
    if mlhormsp ^='' then trt3=strip(trt3)||', '||strip(mlhormsp);

    if mlradi= 'Checked' then trt4 = 'Radiation Therapy';
    if mlradisp ^='' then trt4=strip(trt4)||', '||strip(mlradisp);

    if mloth= 'Checked' then trt5 = 'Other';
    if mlothsp ^='' then trt5=strip(trt5)||', '||strip(mlothsp);

    treatmnt=catx('; ',trt1,trt2,trt3,trt4,trt5);

    if mlcancer = 'Checked' then can1 = 'Family history of cancer';
    if mlcancrs ^='' then can1=strip(can1)||', '||strip(mlcancrs);

    if mlovrwt = 'Checked' then can2 = 'History of being >30 lbs overweight';
    if mlovrwts ^='' then can2=strip(can2)||', '||strip(mlovrwts);

    if mlradiat = 'Checked' then can3 = 'Radiation therapy of the body before age 30';
    if mlradits ^='' then can3=strip(can3)||', '||strip(mlradits);

    if mlalcohl = 'Checked' then can4 = 'Alcohol ingestion';
    if mlalcohs ^='' then can4=strip(can4)||', '||strip(mlalcohs);

    if mlsmoke = 'Checked' then can5 = 'Smoking';
    if mlsmokes ^='' then can5=strip(can5)||', '||strip(mlsmokes);

    if mlothr = 'Checked' then can6 = 'other';
    if mlothrs ^='' then can6=strip(can6)||', '||strip(mlothrs);

    cancer=catx('; ',can1,can2,can3,can4,can5,can6);

    ** Ken Cao on 2015/02/28: Combine MLFIND and MLFINDSP;
    if mlfind = 'Yes' then mlfindsp = 'Yes, '||mlfindsp;
    else mlfindsp = mlfind;
    label mlfindsp = 'Biopsy/Pathology Findings';

    ** Ken Cao on 2015/02/28: Combine MLTHERA/MLTHERNR and MLCYTO/MLCYTONR;
    if mlthernr > ' ' then mlthera = 'Not Reported';
    if mlcytonr > ' ' then mlcyto = 'Not Reported';
    
run;
proc sort; by subject mldtc;run; 

data mldtc;
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set ml; 
       rc = h.find();
       %concatdy(mldtc); 
       drop rc;
    run;

/*
data pdata.ml(label='Other Malignancy');
    retain __edc_treenodeid __edc_entrydate subject mldtc mlfind mlfindsp mlstaget mlstagen mlstagem mlstageo  treatmnt mltxnone 
      mlout mlintent mlantitx mlthera mlthernr mlcyto mlcytonr mlsrnone cancer seq
    manum mlaeno01 mlaeno02 mlaeno03 mlmhno01 mlmhno02 mlmhno03;
    keep __edc_treenodeid __edc_entrydate subject mldtc mlfind mlfindsp mlstaget mlstagen mlstagem mlstageo treatmnt mltxnone 
    mlout mlintent mlantitx mlthera mlthernr mlcyto mlcytonr mlsrnone cancer seq
    manum mlaeno01 mlaeno02 mlaeno03 mlmhno01 mlmhno02 mlmhno03;
    label  mldtc ="Assessment Date"
             treatmnt ="Treatment"
             cancer ="Subject's cancer risks"
;;
    set ml;
run;
*/

data pdata.ml1(label='Other Malignancy');
    retain  __edc_treenodeid __edc_entrydate subject manum mldiag mldtc mlfindsp mlstaget mlstagen mlstagem mlstageo;
    keep  __edc_treenodeid __edc_entrydate subject manum  mldiag mldtc mlfindsp mlstaget mlstagen mlstagem mlstageo;
    set ml;
    label  mldtc ="Date of Diagnosis";
    label manum = 'Record Number';
    label mlstaget = 'Primary Tumor(T)';
    label mlstagen = 'Regional Lymph Nodes (N)';
    label mlstagem = 'Distant Metastasis (M)';
    label mlstageo = 'Other Staging (describe)';
run;

data pdata.ml2(label='Other Malignancy (Continued)');
    retain  __edc_treenodeid __edc_entrydate subject manum treatmnt mlout mlintent mlantitx mlthera mlcyto  cancer;
    keep  __edc_treenodeid __edc_entrydate subject manum treatmnt mlout mlintent mlantitx mlthera mlcyto  cancer;
    set ml;
    label treatmnt ="Treatment";
    label cancer ="Subject's cancer risks";
    label manum = 'Record Number';
    label mlintent = 'If treatment was administered with curative intent';
run;
