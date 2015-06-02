%include '_setup.sas';
**** Prior Local Cancer Therapy ****;
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

   value CMSCAT
      1 = 'Surgery'
      2 = 'Radiation'
      99 = 'Other'
      . = " "
   ;

run;
proc sql;
	create table plall as
	select a.*,b. PLYN as PLYN_, b.SUBID as SUBID_,b.ID as ID_
	from source.lctd as a full join source.pl as b
	on a.SUBID=b.SUBID and a.PARENT=b.ID;
quit;
data pl1;
	length PLYN INDC TYPE SGTYPE SGTH DOSE CMTRT $200;
	set plall;
	%formatDate(PLSTDTC);
	%formatDate(PLENDDTC);
	format _all_;
	label 
		PLYN='Any Prior Local# Cancer Therapy?'
		INDC='Indication'
		TYPE='Type'
		SGTYPE='If Surgery,# Diagnostic or Therapeutic?'
		SGTH='If Therapeutic,# Curative or Palliative?'
		PLSTDTC='Start Date'
		PLENDDTC='Stop Date'
		DOSE='Dose (unit)'
	;
	if SUBID='' and SUBID_^='' then SUBID=SUBID_;
	if ID=. and ID_^=. then ID=ID_;
	if PLYN_=1 then PLYN='Yes';
		else if PLYN_=0 then PLYN='No';
	INDC=strip(put(PLIND,PSINDC.));
	if INDC='Other' then INDC='Other: '||strip(PLINDSP);
	TYPE=strip(put(PLTYPE,CMSCAT.));
	if TYPE='Other' then TYPE='Other: '||strip(PLTYPESP);
	if PLSGTYPE=1 then SGTYPE='Diagnostic';
		else if PLSGTYPE=2 then SGTYPE='Therapeutic';
	if PLSGTH=1 then SGTH='Curative';
		else if PLSGTH=2 then SGTH='Palliative';
	if PLCUDSNA=1 then PLCUDS='NA';
	if PLUNITNA=1 then PLUNIT='NA';
	DOSE=strip(PLCUDS)||' '||strip(PLUNIT);
	CMTRT=strip(upcase(PLRX));
	keep SUBID ID PLYN INDC TYPE PLRX CMTRT SGTYPE SGTH PLLOC DOSE PLSTDTC PLENDDTC;
run;
proc sort data=pl1;by SUBID PLSTDTC CMTRT;run;
data pdata.cm02(label='Prior Local Cancer Therapy');
	retain SUBID INDC TYPE PLRX SGTYPE SGTH PLLOC DOSE PLSTDTC PLENDDTC __ID; 
	keep SUBID INDC TYPE PLRX SGTYPE SGTH PLLOC DOSE PLSTDTC PLENDDTC __ID;
	set pl1(rename=ID=__ID);
	if PLYN='Yes';
run; 
