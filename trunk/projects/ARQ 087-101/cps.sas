/*
	For safety patient profile of ARQ 087-101. Prior and Concomitant Medication.
*/

%include '_setup.sas';

/*libname source 'Q:\Files\C107\ARQ-087\ARQ087-101\cdisc\dev\data\raw';*/
/*libname pdata 'Q:\Files\CDM\Patient Profile\output\ARQ 087-101\processed data';*/
/*%include "Q:\Files\C107\ARQ-087\ARQ087-101\cdisc\dev\data\raw/formats.sas";*/

proc format;

/* arql/014/sgploc - Anatomical Location */
  value sgploc
    1 = "Abdomen"
    2 = "Adrenal Gland - Left"
    3 = "Adrenal Gland - Right"
    4 = "Biliary Tract"
    5 = "Bladder (Urinary)"
    6 = "Brain"
    7 = "Breast - Left"
    8 = "Breast - Right"
    9 = "Cervix"
    10 = "Chest Wall"
    11 = "Colon - Ascending"
    12 = "Colon - Sigmoid"
    13 = "Colon - Transverse"
    14 = "Esophagus"
    15 = "Fallopian Tubes"
    16 = "Gallbladder"
    17 = "Head and Neck"
    18 = "Heart"
    19 = "Kidney - Left"
    20 = "Kidney - Right"
    21 = "Liver"
    22 = "Lung LLL"
    23 = "Lung LML"
    24 = "Lung LUL"
    25 = "Lung RLL"
    26 = "Lung RML"
    27 = "Lung RUL"
    28 = "Lymph Node(s) (Specify)"
    29 = "Mediastinum"
    30 = "Muscle"
    31 = "Oral"
    32 = "Ovary - Left"
    33 = "Ovary - Right"
    34 = "Pancreas - Head"
    35 = "Pancreas - Body"
    36 = "Peritoneum"
    37 = "Pleura"
    38 = "Prostate"
    39 = "Rectum"
    40 = "Skin"
    41 = "Spleen"
    42 = "Testis - Left"
    43 = "Testis - Right"
    44 = "Uterus"
    99 = "Other (Specify)"
  ;
run;

proc sort data=source.cps out=s_cps;
by subid cpsyn cpsterm cpsdtc cpsloc cpslocsp cpsind;
run;

data cps0;
	length PDATA $8 SUBID $40 CPSYN $8 CPSTERM $200 CPSDTC $20 CPSLOC $200 CPSIND $200;
	set s_cps(rename=(SUBID=_SUBID CPSYN=_CPSYN CPSTERM=_CPSTERM CPSDTC=_CPSDTC CPSLOC=_CPSLOC CPSLOCSP=_CPSLOCSP CPSIND=_CPSIND));
	PDATA='CPS';
	SUBID=strip(_SUBID);
	if _CPSYN=1 then CPSYN="Yes"; else if _CPSYN = 0 then CPSYN="No" ; else CPSYN = '';
	if _CPSTERM ^='' then CPSTERM = strip(_CPSTERM);
	if _CPSDTC ^='' then CPSDTC = strip(_CPSDTC);
/*	if _CPSLOC=99 then CPSLOC=strip(_CPSLOCSP);*/
/*		else if _CPSLOC ^=. then CPSLOC=strip(put(_CPSLOC,sgploc.));*/
	if _CPSLOC=99 and _CPSLOCSP^='' then CPSLOC='Other: '||strip(_CPSLOCSP);
		else if _CPSLOC=99 then CPSLOC='Other';
			else if _CPSLOC=28 and _CPSLOCSP^='' then CPSLOC='Lymph Node(s): '||strip(_CPSLOCSP);
				else if _CPSLOC=28 then CPSLOC='Lymph Node(s)';
					else if _CPSLOC^=. then CPSLOC=strip(put(_CPSLOC,SGPLOC.));

	if _CPSIND ^='' then CPSIND = strip(_CPSIND);
	
	keep PDATA SUBID CPSYN CPSTERM CPSDTC CPSLOC CPSIND;
run;

proc sort data=cps0 out=cps_out nodupkey; by PDATA SUBID CPSYN CPSTERM CPSDTC CPSLOC CPSIND; run;

proc sort data=cps_out; by SUBID CPSDTC; run;

data pdata.cps(label='Concurrent Procedure/Surgery');
   attrib
      SUBID     label = "Subject ID"                         length = $40
      PDATA     label = "Source Data"                        length = $8
/*      CPSYN     label = "Surgery/Procedure"                  length = $8*/
      CPSYN     label = "Any Procedures/Surgeries during the study?"                  length = $8
      CPSTERM   label = "Surgery/Procedure Name"             length = $200
/*      CPSDTC    label = "Procedure Date Char"                length = $20*/
      CPSDTC    label = "Procedure Date"                length = $20
      CPSLOC     label = "Anatomical Location"               length = $200
      CPSIND     label = "Indication"                        length = $200
;
	set cps_out;
	keep /*PDATA*/ SUBID CPSYN CPSTERM CPSDTC CPSLOC CPSIND;
run;














	
