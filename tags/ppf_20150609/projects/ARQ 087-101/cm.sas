/*
	For safety patient profile of ARQ 087-101. Prior and Concomitant Medication.
*/

%include '_setup.sas';

/*libname source 'Q:\Files\C107\ARQ-087\ARQ087-101\cdisc\dev\data\raw';*/
/*libname pdata 'Q:\Files\CDM\Patient Profile\output\ARQ 087-101\processed data';*/
/*%include "Q:\Files\C107\ARQ-087\ARQ087-101\cdisc\dev\data\raw/formats.sas";*/

proc format;
/* arql/014/psunit - Dose Units */
  value psunit
    1 = "Tablet"
    2 = "Capsule"
    3 = "mg/m2"
    4 = "mg/kg"
    5 = "mg"
    6 = "IU"
    7 = "gtt"
    8 = "puffs"
    9 = "units"
    10 = "ug"
    11 = "g"
    12 = "Not Applicable"
    13 = "Unknown"
    99 = "Other (Specify)"
  ;
  /* arql/014/psfreq - Frequency */
  value psfreq
    1 = "Once a Day"
    2 = "Twice a Day"
    3 = "Three Times a Day"
    4 = "Continuous IV"
    5 = "As Needed"
    6 = "Every Other Day"
    7 = "One Time Only"
    99 = "Other (Specify)"
  ;
run;

proc sort data=source.cm out=s_cm; 
by subid cmname cmprior cmstdtc cmenddtc cmong cmdose cmunit cmunitsp cmfreq cmfreqsp cmae cmind cmaedtc m_pt1 m_pt2 m_pt3;
run;

data cm0;
	length PDATA $8 SUBID $40 CMNAME $200 CMPRIOR $8  CMSTDTC $20 CMEN $20 /*CMDOSE 8*/ CMDOSE $8 CMUNIT $40 CMFREQ $40 
		   CMAE $1 CMIND $200 CMAEDTC $20 M_PT1 $200 M_PT2 $200 M_PT3 $200 CMROUTE $200;
	set s_cm(rename=(subid=_subid cmname=_cmname cmprior=_cmprior cmstdtc=_cmstdtc cmenddtc=_cmenddtc cmong=_cmong cmdose=_cmdose 
					 cmunit=_cmunit cmunitsp=_cmunitsp cmfreq=_cmfreq cmfreqsp=_cmfreqsp cmae=_cmae cmind=_cmind cmaedtc=_cmaedtc 
					 m_pt1=_m_pt1 m_pt2=_m_pt2 m_pt3=_m_pt3 CMROUTE=_CMROUTE CMROUTSP=_CMROUTSP));
	PDATA = 'CM';
	SUBID=STRIP(_SUBID);
	CMNAME=STRIP(_CMNAME);
	if _CMPRIOR=1 then CMPRIOR='Yes';
		else CMPRIOR='No'; 
	if _CMSTDTC ^='' then CMSTDTC = strip(_CMSTDTC);
	if _CMONG=1 then CMEN='Ongoing';
		else if _cmenddtc^='' then CMEN=strip(_cmenddtc);
/*	CMDOSE=_CMDOSE;*/
	if _CMDOSE^=. then CMDOSE=strip(put(_CMDOSE,best.));
/*	if _CMUNIT=99 then CMUNIT=strip(_CMUNITSP);*/
/*		else if _CMUNIT ^=. then CMUNIT=put(_CMUNIT,psunit.);*/
	if _CMUNIT=99 then do;
		if _CMUNITSP^='' then CMUNIT='Other: '||strip(_CMUNITSP);
			else CMUNIT='Other';
	end;
		else if _CMUNIT ^=. then CMUNIT=put(_CMUNIT,psunit.);
/*	if _CMFREQ=99 then CMFREQ=strip(_CMFREQSP);*/
/*		else if _CMFREQ ^=. then CMFREQ=put(_CMFREQ,psfreq.);*/
	if _CMFREQ=99 then do;
		if _CMFREQSP^='' then CMFREQ='Other: '||strip(_CMFREQSP);
			else CMFREQ='Other';
	end;
		else if _CMFREQ ^=. then CMFREQ=put(_CMFREQ,psfreq.);
	if _CMAE=1 then CMAE='Yes';
/*		else CMAE='No';*/
	if _CMIND ^='' then CMIND = strip(_CMIND);
	if _CMAEDTC ^='' then CMAEDTC = strip(_CMAEDTC);
	if _M_PT1 ^='' then M_PT1=strip(_M_PT1);
	if _M_PT2 ^='' then M_PT2=strip(_M_PT2);
	if _M_PT3 ^='' then M_PT3=strip(_M_PT3);
	if _CMROUTE=99 then do;
		if _CMROUTSP^='' then CMROUTE='Other: '||strip(_CMROUTSP);
			else CMROUTE='Other';
	end;
		else if _CMROUTE ^=. then CMROUTE=put(_CMROUTE,CMROUTE.);
	
	keep PDATA SUBID CMNAME CMPRIOR CMSTDTC CMEN CMDOSE CMUNIT CMROUTE CMFREQ CMAE CMIND CMAEDTC M_PT1 M_PT2 M_PT3;
run;

proc sort data=cm0 out=cm_out nodupkey; 
by PDATA SUBID CMNAME CMPRIOR CMSTDTC CMEN CMDOSE CMUNIT CMROUTE CMFREQ CMAE CMIND CMAEDTC M_PT1 M_PT2 M_PT3;
run;

proc sort data=cm_out; by SUBID CMSTDTC; run;

data pdata.cm(label='Prior and Concomitant Medication');
   attrib
      SUBID     label = "Subject ID"                         length = $40
      PDATA     label = "Source Data"                        length = $8
      CMNAME    label = "Drug Name"                          length = $200
      CMPRIOR   label = "Prior Study"                        length = $8
      CMSTDTC   label = "Start Date"                         length = $20
/*      CMEN      label = "CMEN"                               length = $200*/
      CMEN      label = "Stop Date"                               length = $200
/*      CMDOSE    label = "Dose"                               length = 8*/
      CMDOSE    label = "Dose"                               length = $8
      CMUNIT    label = "Dose Unit"                          length = $40
	  CMROUTE   label ='Route'   length=$200
      CMFREQ    label = "Frequency"                          length = $40
/*      CMAE      label = "CMAE"                               length = $8*/
      CMAE      label = "Is this for AE?"                               length = $1
      CMIND     label = "Indication or AE Term"                         length = $200
/*      CMAEDTC   label = "Onset Date"                         length = $20*/
      CMAEDTC   label = "Onset Date of AE"                         length = $20
      M_PT1     label = "Preferred Term 1"                   length = $200
      M_PT2     label = "Preferred Term 2"                   length = $200
      M_PT3     label = "Preferred Term 3"                   length = $200
	  ;
	set cm_out;
	keep /*PDATA*/ SUBID CMNAME CMPRIOR CMSTDTC CMEN CMDOSE CMUNIT CMROUTE CMFREQ CMAE CMIND CMAEDTC /*M_PT1 M_PT2 M_PT3*/;
run;
