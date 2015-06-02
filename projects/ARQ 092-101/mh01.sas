%include '_setup.sas';
**** Cancer History ****;
proc format;
   value CHTYPE
    1 = "Bladder"
    2 = "Breast"
    3 = "Colorectal"
    4 = "Esophageal"
    5 = "Head and Neck"
    6 = "Liver"
    7 = "Ovarian"
    8 = "NSCLC"
    9 = "Prostate"
    10 = "Renal"
    11 = "Stomach"
    12 = "Pancreatic"
    13 = "Hodgkins Lymphoma"
    14 = "Non-Hodgkins Lymphoma (transformed from CLL)"
    15 = "Non-Hodgkins Lymphoma (NOT transformed from CLL)"
    99 = "Other"
      . = " "
   ;

   value CHBIOP
      1 = 'Fine Needle Aspiration Biopsy'
      2 = 'Core Needle Biopsy'
      3 = 'Excisional Biopsy'
      4 = 'Brushing/Washing'
      5 = 'Surgery'
      99 = 'Other'
      . = " "
   ;

   value CHGRADE
      1 = 'Well Differentiated'
      2 = 'Moderately Differentiated'
      3 = 'Poorly Differentiated/Undifferen tiated'
      99 = 'Unknown'
      . = " "
   ;

   value CHSTGD
      1 = '0'
      2 = 'I A'
      3 = 'I B'
      4 = 'II A'
      5 = 'II B'
      6 = 'III'
      7 = 'IV'
      8 = 'IE-A'
      9 = 'IE-B'
      10 = 'IIE-A'
      11 = 'IIE-B'
      12 = 'III-A'
      13 = 'III-B'
      14 = 'IIIE-A'
      15 = 'IIIE-B'
      16 = 'IIISE-A'
      17 = 'IIISE-B'
      18 = 'IV-A'
      19 = 'IV-B'
      99 = 'Other'
       . = " "
   ;

   value CHSTGE
    1 = "0"
    2 = "I A"
    3 = "I B"
    4 = "II A"
    5 = "II B"
    6 = "III"
    7 = "IV"
    8 = "N/A"
    9 = "IE-A"
    10 = "IE-B"
    11 = "IIE-A"
    12 = "IIE-B"
    13 = "III-A"
    14 = "III-B"
    15 = "IIIE-A"
    16 = "IIIE-B"
    17 = "IIISE-A"
    18 = "IIISE-B"
    19 = "IV-A"
    20 = "IV-B"
    99 = "Other"
     . = " "
   ;
run;
data ch1;
	length MHSCAT PRIM MHTERM BPTYPE GRADE STGD STGE $200;
	set source.ch;
	%formatDate(CHDGDTC);
	format _all_;
	label 
		MHSCAT='Diagnosis Information/Cancer Types'
		PRIM='Current or Previous Cancer?'
		BPTYPE='Type of Biopsy or Procedure'
		CHDGDTC='Date'
		GRADE='Grade'
		STGD='Diagnosis'
		STGE='Study Entry'
	;
	MHSCAT=strip(put(CHTYPE,CHTYPE.));
	if MHSCAT='Other' then MHSCAT='Other: '||strip(CHTYPESP);
	if CHPRIM=1 then PRIM='Current Cancer';
		else if CHPRIM=2 then PRIM='Previous Cancer';
	MHTERM=strip(upcase(CHHISTOL));
	BPTYPE=strip(put(CHBIOP,CHBIOP.));
	if CHBIOP in (5,99) then BPTYPE=strip(BPTYPE)||': '||strip(CHBIOPSP);
	else if CHBIOP not in (5,99) and CHBIOPSP^='' then BPTYPE=strip(BPTYPE)||': '||strip(CHBIOPSP);
	GRADE=strip(put(CHGRADE,CHGRADE.));
	STGD=strip(put(CHSTGD,CHSTGD.));
	if STGD='Other' then STGD='Other: '||strip(CHSTGDSP);
	STGE=strip(put(CHSTGE,CHSTGE.));
	if STGE='Other' then STGE='Other: '||strip(CHSTGESP);
	keep SUBID ID MHSCAT PRIM CHHISTOL MHTERM CHMSUB CHLOCATE BPTYPE CHDGDTC GRADE STGD STGE;
run;
proc sort data=ch1;by SUBID CHDGDTC MHTERM;run;
data pdata.mh01(label='Cancer History');
	retain SUBID MHSCAT PRIM CHHISTOL CHMSUB CHLOCATE BPTYPE CHDGDTC GRADE STGD STGE __ID; 
	keep SUBID MHSCAT PRIM CHHISTOL CHMSUB CHLOCATE BPTYPE CHDGDTC GRADE STGD STGE __ID;
	set ch1(rename=ID=__ID);
run; 
