/*********************************************************************
 Program Nmae: ph.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data ph0;
    set source.ph;
	%subject;
	keep EDC_TreeNodeID SUBJECT VISIT PHSTDY PHSTMO PHSTYY PHNA PHHIST1 PHIST1SP PHHIST2 PHHIST3 PHIST3SP PHHIST4 PHHIST5
         PHHIST6 PHHIST7 PHIST7SP PHHIST8 PHIST8SP PHSTAGE PHSTAGET PHSTAGEN PHSTAGEM PHOSTGSP PHSTAGE PHSTAGET 
         PHSTAGEN PHSTAGEM PHOSTGSP EDC_EntryDate;
run;

data ph1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set ph0;
    
    %let hislab = %nrstr(Subject%'s cancer risks (mark all that apply));
    length phstdtc $20 _phna _phhis1-_phhis8 $255;
    label  phstdtc = "Date of Initial Diagnosis"
             _phna = "None@:&hislab"
           _phhis1 = "Family history of cancer (specify)@:&hislab"
           _phhis2 = "History of being >30 lbs overweight@:&hislab"
		   _phhis3 = "Radiation therapy of the body before age 30(specify location)@:&hislab"
		   _phhis4 = "Alcohol ingestion@:&hislab"
		   _phhis5 = "Smoking/Tobacco use@:&hislab"
		   _phhis6 = "Chronic pancreatitis@:&hislab"
           _phhis7 = "Known genetic abnormality (eg. KRAS, etc.)(specify)@:&hislab"
		   _phhis8 = "Other (specify)@:&hislab"

           phstage = "Pancreatic cancer stage at time of enrollment"
          phstaget = "Primary Tumor (T)@:Staging"
          phstagen = "Regional Lymph Nodes (N)@:Staging"
          phstagem = "Distant Metastases (M):@:Staging"
          phostgsp = "Other Staging (please describe)"
          ;
	%concatdate(year=phstyy, month=phstmo, day=phstdy, outdate=phstdtc);
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(phstdtc);
    drop phstyy phstmo phstdy;
    
	array phhis(*)phna phhist1-phhist8;
    array phhisr(*)_phna _phhis1-_phhis8;
	   do i = 1 to dim(phhis);
	      if phhis[i] = 'Checked' then phhisr[i] = 'Yes';
    end;

	_phhis1 = catx(': ', _phhis1, phist1sp);
    _phhis3 = catx(': ', _phhis3, phist3sp);
	_phhis7 = catx(': ', _phhis7, phist7sp);
	_phhis8 = catx(': ', _phhis8, phist8sp);

    drop phna phhist1-phhist8;
run;


proc sort data = ph1; by subject phstdtc; run;


data pdata.ph1(label='Disease History - Pancreatic Cancer (Part 1)');
    retain EDC_TreeNodeID EDC_EntryDate subject visit phstdtc _phna _phhis1 _phhis2 _phhis3 _phhis4 _phhis5 _phhis6;
	keep   EDC_TreeNodeID EDC_EntryDate subject visit phstdtc _phna _phhis1 _phhis2 _phhis3 _phhis4 _phhis5 _phhis6;

	set ph1;
	rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
	rename          visit = __visit;

run;

data pdata.ph2(label='Disease History - Pancreatic Cancer (Part 2)');
    retain EDC_TreeNodeID EDC_EntryDate subject visit _phhis7 _phhis8 phstage phstaget phstagen phstagem phostgsp;
	keep   EDC_TreeNodeID EDC_EntryDate subject visit _phhis7 _phhis8 phstage phstaget phstagen phstagem phostgsp;

	set ph1;
	rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
	rename          visit = __visit;

run;
 
