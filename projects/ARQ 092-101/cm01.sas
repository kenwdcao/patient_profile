%include '_setup.sas';
**** Prior Systemic Cancer Therapy ****;
proc format;
   value PSINDC
      1 = 'Bladder'
      2 = 'Breast'
      3 = 'Colorectal'
      4 = 'Esophageal'
      5 = 'Head and Neck'
      6 = 'Liver'
      7 = 'Ovarian'
      8 = 'NSCLC'
      9 = 'Prostate'
      10 = 'Renal'
      11 = 'Stomach'
      12 = 'Pancreatic'
      13 = "Hodgkins Lymphoma"
      14 = "Non-Hodgkins Lymphoma"
      99 = 'Other'
      . = " "
   ;

   value CMUNIT
      1 = 'Tablet'
      2 = 'Capsule'
      3 = 'mg/m2'
      4 = 'mg/kg'
      5 = 'mg'
      6 = 'IU'
      7 = 'gtt'
      8 = 'puffs'
      9 = 'units'
      10 = 'ug'
      11 = 'g'
      12 = 'Not Applicable'
      13 = 'Unknown'
      99 = 'Other'
      . = " "
   ;

   value PSSCAT
      1 = 'Neo-adjuvant'
      2 = 'Adjuvant'
      3 = '1st Line'
      4 = '2nd Line'
      5 = '3rd Line or Greater'
      99 = 'Other'
      . = " "
   ;

   value CMBESTRE
      1 = 'Complete Response'
      2 = 'Partial Response'
      3 = 'Stable Disease'
      4 = 'Progressive Disease'
      5 = 'Not Applicable'
      . = " "
   ;
run;
proc sql;
	create table psall as
	select a.*,b. PSYN as PSYN_, b.SUBID as SUBID_,b.ID as ID_
	from source.psd as a full join source.ps as b
	on a.SUBID=b.SUBID and a.PARENT=b.ID;
quit;

data ps1;
	length PSYN INDC DOSE INTD BRES CMTRT PSNUM_ $200;
	set psall;
	%formatDate(PSSTDTC);
	%formatDate(PSENDDTC);
	%formatDate(PSPGDTC);
	%formatDate(PSBRDTC);
	format _all_;
	label 
		PSYN='Any Prior Systemic# Cancer Therapy?'
		INDC='Indication'
		PSSTDTC='Start Date'
		PSENDDTC='Stop Date'
		DOSE='Dose (unit)'
		PSPGDTC='Date of Progression'
		INTD='Intended For'
		BRES='Best Response'
		PSBRDTC='Earliest Date of Best Response'
		PSNUM_='Number of Courses'
	;
	if SUBID='' and SUBID_^='' then SUBID=SUBID_;
	if ID=. and ID_^=. then ID=ID_;
	if PSYN_=1 then PSYN='Yes';
		else if PSYN_=0 then PSYN='No';
	INDC=strip(put(PSIND,PSINDC.));
	if INDC='Other' then INDC='Other: '||strip(PSINDSP);
	UNIT=strip(put(PSUNIT,CMUNIT.));
	if PSUNIT=99 then UNIT=strip(PSUNITSP);
	if PSDOSE^=. then DOSE=strip(put(PSDOSE,best.))||' '||strip(UNIT);
	else if PSDOSE=. then DOSE=strip(UNIT);
	if PSPGDTC='' and PSPGDTNA=1 then PSPGDTC='NA';
	INTD=strip(put(PSINTD,PSSCAT.));
	if INTD='Other' then INTD='Other: '||strip(PSINTDSP);
	BRES=strip(put(PSBRES,CMBESTRE.));
	CMTRT=strip(upcase(PSNAME));
	if PSNUM ^=. then PSNUM_=strip(put(PSNUM,best.)); 
	keep SUBID ID PSYN INDC PSREG PSNAME CMTRT PSSTDTC PSENDDTC DOSE PSSCHED PSNUM_ PSPGDTC INTD BRES PSBRDTC;
run;
proc sort data=ps1;by SUBID PSSTDTC CMTRT;run;
data pdata.cm01(label='Prior Systemic Cancer Therapy');
	retain SUBID INDC PSREG PSNAME PSSTDTC PSENDDTC DOSE PSSCHED PSNUM_ PSPGDTC INTD BRES PSBRDTC __ID; 
	keep SUBID INDC PSREG PSNAME PSSTDTC PSENDDTC DOSE PSSCHED PSNUM_ PSPGDTC INTD BRES PSBRDTC __ID;
	set ps1(rename=ID=__ID);
	if PSYN='Yes';
run; 
