/*
    Program Name: extra04.sas
        @Author: Xiu Pan
        @Initial Date: 2014/08/26
*/
%include '_setup.sas';
proc format;
	value organ
	1 = 'Liver'
	2 = 'Spleen'
	3 = 'Lymph Node'
	4 = 'Bone Marrow'
	99 = 'Other' 
	;

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
	99= 'Other'
	;

run;
proc sql;
	create table exl_lnw as
	select a.*,b.exnwnod,b.exnworg,b.worgsp,b.exnwloc,b.exnwmod,b.exnwmosp,b.exnwst,b.exnwpet,b.exnwptsp,b.subid_lnw
	from source.exl(where=(exna^=1)) as a full join source.lnw(rename=(subid=subid_lnw)) as b
	on a.subid=b.subid_lnw and a.id=b.parent
	;
quit;

data extra;
	set exl_lnw;
	format _all_;
	attrib
	tudtc  			label='Assessment Date'										length=$19
	visit			label='Visit'												length=$60
	visitnum		label='Visit Number'										length=8
	tuoth			label='Other Organ Involvement?'							length=$20
	meaoth			label='Other Measurable Disease?'							length=$20
	tunew			label='New Sites?'											length=$100
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
	if exothor=1 then tuoth='No';
		else if exothor=2 then tuoth='Yes';
	if exotmea=0 then meaoth='No';
		else if exotmea=1 and measp='' then meaoth='Yes';
			else if exotmea=1 and measp^='' then meaoth='Yes: '||strip(measp);
	if exnew=0 then tunew='No';
		else if exnew=1 then tunew='Yes';
			else if exnew=2 then tunew='Not Applicable';
	if exnwnod^=. then nodnum=strip(put(exnwnod,best.));
	if exnworg=99 and worgsp^='' then organ="Other: "||strip(worgsp);
		else if exnworg^=. and worgsp='' then organ=strip(put(exnworg,method.));
	tuloc=strip(exnwloc);
	if exnwmod=99 and exnwmosp^='' then method="Other: "||strip(exnwmosp);
		else if exnwmod^=. and exnwmosp='' then method=strip(put(exnwmod,method.));
	if exnwst=1 then status='Present';
		else if exnwst=2 then status='Absent';
	if exnwpet=99 and exnwptsp^='' then petores="Other: "||strip(exnwptsp);
		else if exnwpet^=. and exnwptsp='' then petores=strip(put(exnwpet,expet.));

	keep subid tudtc visit visitnum tuoth meaoth tunew nodnum organ tuloc method status petores exnwnod;
run;

proc sort data=extra; by subid tudtc visitnum exnwnod; run;

data pdata.extra04(label='Extranodal Disease Assessment: New Nodules');
	retain subid visit tudtc tuoth meaoth tunew nodnum organ tuloc method status petores;
	keep subid visit tudtc tuoth meaoth tunew nodnum organ tuloc method status petores;
	set extra;
run;
