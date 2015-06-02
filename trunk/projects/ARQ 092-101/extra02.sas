/*
    Program Name: extra02.sas
        @Author: Xiu Pan
        @Initial Date: 2014/08/25
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
	create table exl_lsm as
	select a.*,b.exnod,b.exorg,b.exloc,b.exmod,b.exmosp,b.exld,b.expd,b.expod,b.expet,b.expetsp,b.subid_lsm
	from source.exl(where=(exna^=1)) as a full join source.lsm(rename=(subid=subid_lsm)) as b
	on a.subid=b.subid_lsm and a.id=b.parent
	;
quit;

data extra;
	set exl_lsm(rename=exspd=exspd_);
	format _all_;
	attrib
	tudtc  			label='Assessment Date'										length=$19
	visit			label='Visit'												length=$60
	visitnum		label='Visit Number'										length=8
	mnodule			label='Measurable Nodules'									length=$20
	nodnum			label='Nodule Number'										length=$20
	organ			label='Organ'												length=$100
	tuloc			label='Location/Description'								length=$200
	method			label='Assessment Modality'									length=$200
	tuldia			label='Longest Diameter'									length=$20
	tuperdia		label='Perpendicular Diameter'								length=$20
	tuprodia		label='Product of Diameters'								length=$20
	petores			label='PET Results'											length=$100
	exspd			label='SPD'													length=$20

	;

	%formatDate(EXDTC);
	tudtc= exdtc;
	if extype=99 and exvissp^='' then visit=strip(put(strip(put(extype,best.)),$visit.))||'('||strip(exvissp)||')';
		else if extype^=. and exvissp='' then visit=strip(put(strip(put(extype,best.)),$visit.));
	visitnum=input(put(strip(put(extype,best.)),$vnum.),best.);
	if exmnu^=. then mnodule=strip(put(exmnu,best.));
	if exnod^=. then nodnum=strip(put(exnod,best.));
	if exorg=1 then organ='Liver';
		else if exorg=2 then organ='Spleen';
	tuloc=strip(exloc);
	if exmod=99 and exmosp^='' then method="Other: "||strip(exmosp);
		else if exmod^=. and exmosp='' then method=strip(put(exmod,method.));
	if exld^=. then tuldia=strip(put(exld,best.));
	if expd^=. then tuperdia=strip(put(expd,best.));
	if expod^=. then tuprodia=strip(put(expod,best.));
	if expet=99 and expetsp^='' then petores="Other: "||strip(expetsp);
		else if expet^=. and expetsp='' then petores=strip(put(expet,expet.));
	if exspd_^=. then exspd=strip(put(exspd_,best.));

	keep subid tudtc visit visitnum mnodule nodnum organ tuloc method tuldia tuperdia tuprodia 
		petores exspd exnod;
run;

proc sort data=extra; by subid tudtc visitnum exnod; run;

data pdata.extra02(label='Extranodal Disease Assessment: Liver Spleen Measurable Nodules');
	retain subid visit tudtc mnodule nodnum organ tuloc method tuldia tuperdia tuprodia petores exspd;
	keep subid visit tudtc mnodule nodnum organ tuloc method tuldia tuperdia tuprodia petores exspd;
	set extra;
run;
