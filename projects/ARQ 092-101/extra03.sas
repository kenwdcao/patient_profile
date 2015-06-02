/*
    Program Name: extra03.sas
        @Author: Xiu Pan
        @Initial Date: 2014/08/26
*/
%include '_setup.sas';

proc format;
	value method
	1= 'Spiral CT'
	2= 'Conventional CT'
	3= 'MRI'
	4= 'PET'
	5= 'CT Guided PET Scan'
	99= 'Other'
	;

	value expet
	1 = 'Not Done'
	2 = 'Positive'
	3 = 'Negative'
	4 = 'No change from first on-study PET scan'
	5 = 'Increased from first on-study scan'
	6 = 'Decreased from first on-study scan'
	99= 'Other'
	;

run;

proc sql;
	create table exl_lnm as
	select a.*,b.exnmnod,b.exnmorg,b.exnmloc,b.exnmod,b.exnmosp,b.exnmst,b.exnmpet,b.exnmptsp,b.subid_lnm
	from source.exl(where=(exna^=1)) as a full join source.lnm(rename=(subid=subid_lnm)) as b
	on a.subid=b.subid_lnm and a.id=b.parent
	;
quit;

data extra;
	set exl_lnm;
	format _all_;
	attrib
	tudtc  			label='Assessment Date'										length=$19
	visit			label='Visit'												length=$60
	visitnum		label='Visit Number'										length=8
	mnodule			label='Non-Measurable Nodules'								length=$20
	nodnum			label='Nodule Number'										length=$20
	organ			label='Organ'												length=$100
	tuloc			label='Location/Description'								length=$200
	method			label='Assessment Modality'									length=$200
	status			label='Status'												length=$20
	petores			label='PET Results'											length=$100

	;

	%formatDate(EXDTC);
	tudtc= exdtc;
	if extype=99 and exvissp^='' then visit=strip(put(strip(put(extype,best.)),$visit.))||'('||strip(exvissp)||')';
		else if extype^=. and exvissp='' then visit=strip(put(strip(put(extype,best.)),$visit.));
	visitnum=input(put(strip(put(extype,best.)),$vnum.),best.);
	if exnmnu^=. then mnodule=strip(put(exnmnu,best.));
	if exnmnod^=. then nodnum=strip(put(exnmnod,best.));
	if exnmorg=1 then organ='Liver';
		else if exnmorg=2 then organ='Spleen';
	tuloc=strip(exnmloc);
	if exnmod=99 and exnmosp^='' then method="Other: "||strip(exnmosp);
		else if exnmod^=. and exnmosp='' then method=strip(put(exnmod,method.));
	if exnmst=1 then status='Present';
		else if exnmst=2 then status='Absent';

	if exnmpet=99 and exnmptsp^='' then petores="Other: "||strip(exnmptsp);
		else if exnmpet^=. and exnmptsp='' then petores=strip(put(exnmpet,expet.));

	keep subid tudtc visit visitnum mnodule nodnum organ tuloc method status petores exnmnod;
run;

proc sort data=extra; by subid tudtc visitnum exnmnod; run;

data pdata.extra03(label='Extranodal Disease Assessment: Liver Spleen Non-Measurable Nodules');
	retain subid visit tudtc mnodule nodnum organ tuloc method status petores;
	keep subid visit tudtc mnodule nodnum organ tuloc method status petores;
	set extra;
run;
