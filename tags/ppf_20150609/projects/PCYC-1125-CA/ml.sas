/*********************************************************************
 Program Nmae: ML.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/03/16
 
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/18: 1) Add --DY to MLDTC
                        2) Major update.

*********************************************************************/

%include '_setup.sas';

data ml;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    length mldtc $20;
    set source.ml(rename=(mldtc=mldtc_));
    %subject;
    label mldtc="Date of Diagnosis";
    mldtc=mldtc_;
    rc = h.find();
    %concatDY(mldtc);
    if mltnrpt^=. then mltherpy="Not Reported";
        else if mltnrpt=. then mltherpy=strip(mltherpy);
    if mucynrpt^=. then mlcyto="Not Reported";
        else if mucynrpt=. then mlcyto=strip(mlcyto);
    __id=id;
    keep __id subject mldiag mldtc mlfind  mlfindsp mlstagnr mlstaget mlstagen mlstagem mlstag mltxnone mlsurg mlsurgsp
        mlchem mlchemsp mlhorm mlhormsp mlradi mlradisp mloth mlothsp mlout mlintent mlantitx mltherpy mlcyto mlrsnone
        mlcancr mcancrs mlovrwt mlovrwts mlradia mlradias mlalcoho mlalcohs mlsmoke mlsmokes mlothrsk mlothrs mlaeno01
        mlaeno02 mlaeno03 mlaeno04 mlmhno01 mlmhno02 mlmhno03 mlmhno04;
run;


** Ken Cao on 2015/03/18: Shrink variables.;
data ml2;
    set ml;
    
    /*
    ** Biopsy/pathology findings avaiable;
    mlfindsp = vvaluex('mlfind') || ifc(mlfindsp > ' ', '. '||strip(mlfindsp), mlfindsp);
    drop mlfind;
    label mlfindsp = 'Biopsy/pathology Findings Available?';
    */

    label mlstagnr = 'Not Reported';

    ** TREATMENT (mark all that apply):;
    drop mlsurg mlchem mlhorm mlradi mloth;
    array mltx{*} mlsurg mlchem mlhorm mlradi mloth;
    array mltxsp{*} mlsurgsp mlchemsp mlhormsp mlradisp mlothsp;
    label 
        mlsurgsp = 'Surgery'
        mlchemsp = 'Chemotherapy'
        mlhormsp = 'Hormonal Therapy'
        mlradisp = 'Radiation Therapy'
         mlothsp = 'Other'
    ;
    do i = 1 to dim(mltx);
        if mltx[i] = 1 and mltxsp[i] = ' ' then do;
            mltxsp[i] = 'Yes';
        end;
    end;

    ** SUBJECT’S CANCER RISKS;
    drop mlcancr mlovrwt mlradia mlalcoho mlsmoke mlothrsk;
    array mlrs{*} mlcancr mlovrwt mlradia mlalcoho mlsmoke mlothrsk;
    array mlrssp{*} mcancrs mlovrwts mlradias mlalcohs mlsmokes mlothrs;
    label
         mcancrs = 'Family history of cancer'
        mlovrwts = 'History of being >30 lbs overweight'
        mlradias = 'Radiation therapy of the body before age 30'
        mlalcohs = 'Alcohol ingestion'
        mlsmokes = 'Smoking'
         mlothrs = 'Other'
    ;
    do i = 1 to dim(mlrs);
        if mlrs[i] = 1 and mlrssp[i] = ' ' then do;
            mlrssp[i] = 'Yes';
        end;
    end;

    ** Is it likely this additional malignancy is related to any anti-cancer treatment the subject has received;
    length mlantitxs $255;
    label mlantitxs = 'Related to any anti-cancer treatment?';
    mlantitxs = vvaluex('mlantitx');
    if mlthrapy > ' ' then mlthrapy = 'Therapy: '||strip(mlthrapy);
    if mlcyto > ' ' then mlcyto = 'Cytogenetics: '||strip(mlcyto);
    mlantitxs = strip(mlantitxs)||'0D'x||'0A'x||strip(mlthrapy)||'0D'x||'0A'x||strip(mlcyto);
    drop mlantitx mlthrapy mlcyto;
    

    ** AE Numbers;
    length mlaenum $255;
    label mlaenum = 'Corresponding AE No.';
    array mlaeno{*} mlaeno:;
    mlaenum = ' ';
    do i = 1 to dim(mlaeno);
        if mlaeno[i] = . then continue;
        if mlaenum = ' ' then mlaenum = strip(put(mlaeno[i], best.));
        else mlaenum = strip(mlaenum)||', '||strip(put(mlaeno[i], best.));
    end;
    drop mlaeno:;

    ** MH Numbers.;
    length mlmhnum $255;
    label mlmhnum = 'Corresponding MedHx No.';
    array mlmhno{*} mlmhno:;
    mlmhnum = ' ';
    do i = 1 to dim(mlmhno);
        if mlmhno[i] = . then continue;
        if mlmhnum = ' ' then mlmhnum = strip(put(mlmhno[i], best.));
        else mlmhnum = strip(mlmhnum)||', '||strip(put(mlmhno[i], best.));
    end;
    drop mlmhno:;

    drop i;
run;

proc sort data=ml2;by subject mldtc;run;



data pdata.ml1(label="Other Malignancy");
    retain __id subject mldiag mldtc mlfind mlfindsp mlstagnr mlstaget mlstagen mlstagem mlstag ;
    keep __id subject mldiag mldtc mlfind mlfindsp mlstagnr mlstaget mlstagen mlstagem mlstag ;
    set ml2;
run;

data pdata.ml2(label="Other Malignancy (Continued)");
    retain __id subject mldiag mltxnone mlsurgsp mlchemsp mlhormsp mlradisp mlothsp mlout mlintent mlantitxs;
    keep __id subject mldiag mltxnone mlsurgsp mlchemsp mlhormsp mlradisp mlothsp mlout mlintent mlantitxs;
    set ml2;
run;

data pdata.ml3(label="Other Malignancy (Continued 2)");
    retain __id subject mldiag mlrsnone mcancrs mlovrwts mlradias mlalcohs mlsmokes mlothrs mlaenum mlmhnum;
    keep __id subject mldiag mlrsnone mcancrs mlovrwts mlradias mlalcohs mlsmokes mlothrs mlaenum mlmhnum;
    set ml2;
run;
