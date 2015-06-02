/*********************************************************************
 Program Nmae: maligoth.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/29
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data maligoth0;
    set source.maligoth;
    %subject;
    keep EDC_TreeNodeID SUBJECT MALIGTYP DIAGDY DIAGMO DIAGYR BIOPSYYN BIOPSYSP TSTAGE NSTAGE MSTAGE OSTAGESP TRTNA SURG 
         SURGSP CHEM CHEMSP HORM HORMSP RADI RADISP OTH OTHSP STATUSSP MLINTENT ANTIYN MLTHERA MLCYTO CRNA CANCR CANCRSP 
         OVRWT OVRWTSP RADIT RADITSP ALCOH ALCOHSP SMOKE SMOKESP OTHR OTHRSP MALIGSEQ AENO01 AENO02 AENO03 MHNO01 MHNO02 
         MHNO03 EDC_EntryDate;
run;


data maligoth1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set maligoth0;

    rc = h.find();
    drop rc rfstdtc;

	%let trtlab = Treatment (mark all that apply);
	%let hislab = %nrstr(Subject%'s cancer risks (mark all that apply));

    length diagdtc $20;
	label maligtyp = 'Diagnosis (type of malignancy including anatomic site)'
           diagdtc = 'Date of Diagnosis'
          biopsyyn = 'Are biopsy/pathology findings available?'
          biopsysp = "If 'Yes', please specify findings"
            tstage = "Primary Tumor (T)@:Staging"
            nstage = "Regional Lymph Nodes (N)@:Staging"
            mstage = "Distant Metastases (M)@:Staging"
		  ostagesp = "Other Staging (please describe)"
            _trtna = "None@:&trtlab"
             _surg = "Surgery (specify)@:&trtlab"
             _chem = "Chemotherapy (specify)@:&trtlab"
             _horm = "Hormonal therapy (specify)@:&trtlab"

             _radi = "Radiation therapy (specify)@:&trtlab"
              _oth = "Other (specify)@:&trtlab"
	      statussp = "Subject Outcome / Current Status (specify)"
          mlintent = "Check box if treatment was administered with curative intent."
	        antiyn = "Is it likely this additional malignancy is related to any anti-cancer treatment the subject has received (including treatment for this study)?"
           mlthera = "If 'Yes', specify the therapy"
	        mlcyto = "If 'Yes', describe cytogenetics"

             _crna = "None@:&hislab"
            _cancr = "Family history of cancer (specify)@:&hislab"
            _ovrwt = "History of being >30 lbs overweight (specify)@:&hislab"
            _radit = "Radiation therapy of the body before age 30 (specify)@:&hislab"
            _alcoh = "Alcohol ingestion (specify)@:&hislab"
            _smoke = "Smoking/Tobacco use (specify)@:&hislab"
             _othr = "Other (specify)@:&hislab"
         ;

    %concatdate(year=diagyr, month=diagmo, day=diagdy, outdate=diagdtc);
    %concatDY(diagdtc);
    drop diagyr diagmo diagdy;

	
    length _trtna _surg _chem _horm _radi _oth  _crna _cancr _ovrwt _radit _alcoh _smoke _othr $255;
    array _newarr{*} _trtna _surg _chem  _horm _radi _oth  _crna _cancr _ovrwt _radit _alcoh _smoke _othr;
    array _oldarr{*}  trtna  surg  chem   horm  radi  oth   crna  cancr  ovrwt  radit  alcoh  smoke  othr;

    do i = 1 to dim(_newarr);
        if _oldarr[i] = 'Checked' then _newarr[i] = 'Yes';
    end;
   
	if surgsp ^= '' then _surg = strip(_surg) || ': ' || strip(surgsp);
    if chemsp ^= '' then _chem = strip(_chem) || ': ' || strip(chemsp);
	if hormsp ^= '' then _horm = strip(_horm) || ': ' || strip(hormsp);
    if radisp ^= '' then _radi = strip(_radi) || ': ' || strip(radisp);
	if  othsp ^= '' then  _oth =  strip(_oth) || ': ' || strip(othsp);

    if cancrsp ^= '' then _cancr = strip(_cancr) || ': ' || strip(cancrsp);
	if ovrwtsp ^= '' then _ovrwt = strip(_ovrwt) || ': ' || strip(ovrwtsp);
	if raditsp ^= '' then _radit = strip(_radit) || ': ' || strip(raditsp);
	if alcohsp ^= '' then _alcoh = strip(_alcoh) || ': ' || strip(alcohsp);
	if smokesp ^= '' then _smoke = strip(_smoke) || ': ' || strip(smokesp);
	if  othrsp ^= '' then  _othr = strip(_othr)  || ': ' || strip(othrsp);

    length _aeno01 _aeno02 _aeno03 _mhno01 _mhno02 _mhno03  _aeno _mhno $255;
	label _aeno = 'If this malignancy was also considered an adverse event, then provide AE Number';
	label _mhno = 'If this malignancy is of the same tumor type or of a related tumor type to a malignancy reported in medical history, then provide Med Hx Number';

	array t(6) aeno01 aeno02 aeno03 mhno01 mhno02 mhno03;
    array d(6) _aeno01 _aeno02 _aeno03 _mhno01 _mhno02 _mhno03;
	  do j = 1 to 6;
	    if t(j) ^= . then d(j) = strip(put(t(j), best.));
	  end;
    _aeno = catx(', ', of _aeno01 - _aeno03);
    _mhno = catx(', ', of _mhno01 - _mhno03);
run;

proc sort data = maligoth1; by subject diagdtc; run;

data pdata.maligoth1(label='Other Malignancy (Part 1)');
    retain  EDC_TreeNodeID EDC_EntryDate subject maligseq maligtyp diagdtc biopsyyn biopsysp tstage nstage mstage ostagesp _trtna _surg _chem _horm;
    keep    EDC_TreeNodeID EDC_EntryDate subject maligseq maligtyp diagdtc biopsyyn biopsysp tstage nstage mstage ostagesp _trtna _surg _chem _horm;;

    set maligoth1;

    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename       maligseq = __maligseq;
run;


data pdata.maligoth2(label='Other Malignancy (Part 2)');
    retain  EDC_TreeNodeID EDC_EntryDate subject maligseq _radi _oth statussp mlintent antiyn mlthera mlcyto;
    keep    EDC_TreeNodeID EDC_EntryDate subject maligseq _radi _oth statussp mlintent antiyn mlthera mlcyto;

    set maligoth1;

    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename       maligseq = __maligseq;
run;


data pdata.maligoth3(label='Other Malignancy (Part 3)');
    retain  EDC_TreeNodeID EDC_EntryDate subject maligseq _crna _cancr _ovrwt _radit _alcoh _smoke _othr _aeno _mhno;
    keep    EDC_TreeNodeID EDC_EntryDate subject maligseq _crna _cancr _ovrwt _radit _alcoh _smoke _othr _aeno _mhno;

    set maligoth1;

    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename       maligseq = __maligseq;
run;
