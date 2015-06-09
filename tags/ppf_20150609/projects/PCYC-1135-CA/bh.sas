/*********************************************************************
 Program Nmae: bh.sas
  @Author: Ken Cao
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data bh0;
    set source.bh;
    %subject;
    keep EDC_TreeNodeID SUBJECT VISIT BHSTDY BHSTMO BHSTYR BHHIST BHNA BHHIST1 BHIST1SP 
         BHHIST2 BHHIST2A BHIST2SP BHHIST3 BHHIST4 BHIST4SP BHHIST5 BHHIST6 BHHIST7 BHHIST8 
         BHHIST9 BHHIST10 BHHIST11 BHMENOP BHMENOSP BHHIST12 BHHIST13 BHHIST14 BHHIST15 BHHIST16
         BHIS16SP BHHIST17 BHIS17SP BHESTAT BHPSTAT BHHSTAT BHOSTAT BHOTHSP BHSTAGE BHSTAGET BHSTAGEN
         BHSTAGEM BHOSTGSP BHBAGE BHMAGE EDC_EntryDate;
run;

data bh1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set bh0;

    rc = h.find();
    drop rc rfstdtc;
    
    length bhstdtc $20 ;
    %concatdate(year=bhstyr, month=bhstmo, day=bhstdy, outdate=bhstdtc);
    %concatDY(bhstdtc);
    drop bhstyr bhstmo bhstdy;

    length _bhna _bhhist1 - _bhhist17 _bhhist2a $255;
    array _newarr{*} _bhna _bhhist1 - _bhhist17 _bhhist2a;
    array _oldarr{*} bhna bhhist1-bhhist17 bhhist2a;

    do i = 1 to dim(_newarr);
        if _oldarr[i] = 'Checked' then _newarr[i] = 'Yes';
    end;

	if bhist1sp ^= ' ' then _bhhist1  = strip(_bhhist1) ||': '||bhist1sp;
    if bhist2sp ^= ' ' then _bhhist2a = strip(_bhhist2a)||': '||bhist2sp;
    if bhist4sp ^= ' ' then _bhhist4  = strip(_bhhist4) ||': '||bhist4sp;
    if bhbage   ^= .   then _bhhist9  = strip(_bhhist9) ||': '||vvaluex('bhbage');
    if bhmenop  ^= ' ' then _bhhist11 = strip(_bhhist11)||': '||bhmenop;
    if bhis16sp ^= ' ' then _bhhist16 = strip(_bhhist16)||': '||bhis16sp;
    if bhis17sp ^= ' ' then _bhhist17 = strip(_bhhist17)||': '||bhis17sp;

    %let hislab = %nrstr(Subject%'s cancer risks (mark all that apply));

    label   bhstdtc = "Date of Initial Diagnosis"
              _bhna = "None@:&hislab"
           _bhhist1 = "Family history of cancer(specify)@:&hislab"
           _bhhist2 = "Family history of breast cancer@:&hislab"
          _bhhist2a = "This is a hereditary form of breast cancer (specify)@:&hislab"
           _bhhist3 = "History of being >30 lbs overweight@:&hislab"
           _bhhist4 = "Radiation therapy of the body before age 30 (specify location)@:&hislab"
           _bhhist5 = "Prior irradiation of the chest wall@:&hislab"
           _bhhist6 = "Alcohol ingestion@:&hislab"
           _bhhist7 = "Smoking/Tobacco use@:&hislab"
           _bhhist8 = "Early menarche@:&hislab"
           _bhhist9 = "Childbirth after age 30 (specify age)@:&hislab"

          _bhhist10 = "Never given birth@: @:&hislab"
          _bhhist11 = "Menopausal@: @:&hislab"
             bhmage = "If Postmenopausal, specify Age@:Menopausal Sepcify@:&hislab"
           bhmenosp = "If Other, Specify@:Menopausal Sepcify@:&hislab"
          _bhhist12 = "Hormone replacement therapy@: @:&hislab"
          _bhhist13 = "Use of oral contraceptives@: @:&hislab"
          _bhhist14 = "BRCA1 Mutation@: @:&hislab"
          _bhhist15 = "BRCA2 Mutation@: @:&hislab"
          _bhhist16 = "Other known genetic abnormalities(eg. TP53)@: @:&hislab"
          _bhhist17 = "Other (specify)@: @:&hislab"

           bhestat = "Estrogen@:Receptor Status"
           bhpstat = "Progesterone@:Receptor Status"
           bhhstat = "HER2@:Receptor Status"
           bhostat = "Other Receptor@:Receptor Status"
           bhothsp = "If Other, Specify@:Receptor Status"
           bhstage = 'Breast cancer stage at time of enrollment'
          bhstaget = "Primary Tumor (T)@:Staging"
          bhstagen = "Regional Lymph Nodes (N)@:Staging"
          bhstagem = "Distant Metastases (M)@:Staging"
		  bhostgsp = "Other Staging (please describe)"
        ;



    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename          visit = __visit;
run;


proc sort data = bh1; by subject bhstdtc; run;


data pdata.bh1(label='Disease History - Breast Cancer (Part 1)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject __visit bhstdtc bhhist _bhna _bhhist1 _bhhist2 _bhhist2a _bhhist3 _bhhist4
           _bhhist5 _bhhist6 _bhhist7 _bhhist8 _bhhist9;
    keep   __EDC_TreeNodeID __EDC_EntryDate subject __visit bhstdtc bhhist _bhna _bhhist1 _bhhist2 _bhhist2a _bhhist3 _bhhist4
           _bhhist5 _bhhist6 _bhhist7 _bhhist8 _bhhist9;

    set bh1;

run;


data pdata.bh2(label='Disease History - Breast Cancer (Part 2)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject __visit _bhhist10 _bhhist11 bhmage bhmenosp _bhhist12 _bhhist13 
           _bhhist14 _bhhist15 _bhhist16 _bhhist17;
    keep   __EDC_TreeNodeID __EDC_EntryDate subject __visit _bhhist10 _bhhist11 bhmage bhmenosp _bhhist12 _bhhist13 
           _bhhist14 _bhhist15 _bhhist16 _bhhist17;

    set bh1;
run;


data pdata.bh3(label='Disease History - Breast Cancer (Part 3)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject __visit bhestat bhpstat bhhstat bhostat bhothsp bhstage 
           bhstaget bhstagen bhstagem bhostgsp;
    keep   __EDC_TreeNodeID __EDC_EntryDate subject __visit bhestat bhpstat bhhstat bhostat bhothsp bhstage 
           bhstaget bhstagen bhstagem bhostgsp;

    set bh1;
run;
