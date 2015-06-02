/*********************************************************************
 Program Nmae: AM.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/16
*********************************************************************/
%include "_setup.sas";

data am;
    length subject $13 rfstdtc AMRISK1 AMTRT7 $10 amdtc mhnum $20 ambp_ $200;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.am(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate AMTRT7=AMTRT7_ AMRISK1=AMRISK1_));
    %subject;

    label amdtc = 'Date of Diagnosis';
    %ndt2cdt(ndt=amdt, cdt=amdtc);
    rc = h.find();
    %concatDY(amdtc);
    
    if amrelnr=1 then amrelsp='Not Reported';
    if amcytonr=1 then amcyto='Not Reported';
    label ambp_='Are biopsy/pathology findings available?';
    ambp_=ifc(ambpyn='Yes',cat('Yes, ',strip(ambpynsp)),strip(ambpyn));
    
    label AMCURI_='Treatment was administered with curative intent';
    AMCURI_=put(AMCURI,checked.);

    label amrel_='Malignancy related to Anti-Cancer Treat.';
    amrel_=ifc(amrel='Yes',cat('Yes, ',strip(amrelsp),', ', strip(amcyto)),strip(amrel));

    label mhnum='Corresponding Medical History Number';
    mhnum=catx(", ",strip(vvaluex('MHNUM1')),strip(vvaluex('mhnum2')),strip(vvaluex('MHNUM3')));

    if AMRISK1_=1 then AMRISK1=put(AMRISK1_,checked.);
    if AMTRT7_=1 then AMTRT7=put(AMTRT7_,checked.);

    attrib
    amstgt   label='T'
    AMSTGN   label='N'
    AMSTGM   label='M'
    AMSTGOS  label='Other Staging'
    AMTRTD2  label='Surgery'
    AMTRTD3  label='Chemotherapy'
    AMTRTD4  label='Hormonal Therapy'
    AMTRTD5  label='Radiation Therapy'
    AMTRTD6  label='Other'
    AMRISKD2 label='Family history of cancer'
    AMRISKD3 label='History of being >30 lbs overweight'
    AMRISKD4 label='Radiation therapy of the body before age 30'
    AMRISKD5 label='Alcohol ingestion'
    AMRISKD6 label='Smoking'
    AMRISKD7 label='Other'
    AMTRT7   label='None'
    AMRISK1  label='None'
    mhnum    label='Related Med Hx Number';
run;

proc sort data=am;by subject amdtc amterm;run;

data pdata.am1 (label="Other Malignancy");
    retain __edc_treenodeid __edc_entrydate subject amterm amdtc ambp_ amstgt amstgn amstgm amstgos AMTRT7 amtrtd2-amtrtd6;
    set am;
    keep __edc_treenodeid __edc_entrydate subject amterm amdtc ambp_ amstgt amstgn amstgm amstgos AMTRT7 amtrtd2-amtrtd6;

    label amstgt = 'Primary Tumor (T)@:Staging:';
    label amstgn = 'Regional Lymph Nodes (N)@:Staging:';
    label amstgm = 'Distant Metastasis (M)@:Staging:';
    label amstgos = 'Other Staging@:Staging:';


    label AMTRT7 = 'None@:Treatment';
    label amtrtd2 = 'Surgery@:Treatment';
    label amtrtd3 = 'Chemotherapy@:Treatment';
    label amtrtd4 = 'Hormonal therapy@:Treatment';
    label amtrtd5 = 'Radiation therapy@:Treatment';
    label amtrtd6 = 'Other@:Treatment';
run;


data pdata.am2 (label="Other Malignancy (Continued)");
    retain __edc_treenodeid __edc_entrydate subject amterm amdtc amout AMCURI_ amrel_ AMRISK1 amriskd2-amriskd7 amsae mhnum;
    set am;
    keep __edc_treenodeid __edc_entrydate subject amterm amdtc amout AMCURI_ amrel_ AMRISK1 amriskd2-amriskd7 amsae mhnum;


    label AMRISK1 = 'None@:Subject''s cancer risk ';
    label amriskd2 = 'Family history of cancer@:Subject''s cancer risk ';
    label amriskd3 = 'History of being >30 lbs overweight@:Subject''s cancer risk ';
    label amriskd4 = 'Radiation therapy of the body before age 30@:Subject''s cancer risk ';
    label amriskd5 = 'Alcohol ingestion@:Subject''s cancer risk ';
    label amriskd6 = 'Smoking@:Subject''s cancer risk ';
    label amriskd7 = 'Other@:Subject''s cancer risk ';
run;
