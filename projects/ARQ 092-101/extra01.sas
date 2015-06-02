/*
    Program Name: extra01.sas
        @Author: Xiu Pan
        @Initial Date: 2014/08/25
*/
%include '_setup.sas';

proc format;
	value exstat
	1 = 'No change from baseline'
	2 = 'Infiltrate cleared on repeated biopsy OR IHC negative if indeterminate by morphology'
	3 = 'New or recurrent involvement'
	99 = 'Other'
	;

	value size
	1 = 'Normal (not palpable on physical examination and normal size by imaging study)'
	2 = 'Abnormal - enlarged'
	3 = 'No change from baseline'
	4 = 'Increased from baseline'
	5 = 'Decreased from baseline'
	99 = 'Other'
	;
run;

data extra;
	set source.exl;
	where exna^=1;
	format _all_;
	attrib
	tudtc  			label='Assessment Date'					length=$19
	visit			label='Visit'							length=$60
	visitnum		label='Visit Number'					length=8
	bminvol			label='Bone Marrow Involved?'			length=$20
	celltyp			label='Cell Type'						length=$200
	bmstat			label='Bone Marrow Status'				length=$200
	lvinvol			label='Liver Involved?'					length=$20
	lvsize			label='Liver Size'					length=$200
	spinvol			label='Spleen Involved?'				length=$20
	spsize			label='Spleen Size'					length=$200
	;

	if extype=99 and exvissp^='' then visit=strip(put(strip(put(extype,best.)),$visit.))||'('||strip(exvissp)||')';
		else if extype^=. and exvissp='' then visit=strip(put(strip(put(extype,best.)),$visit.));
	visitnum=input(put(strip(put(extype,best.)),$vnum.),best.);
	%formatDate(EXDTC);
	tudtc= exdtc;
	if exbone=0 then bminvol='No';
		else if exbone=1 then bminvol='Yes';
			else if exbone=2 then bminvol='Not Assessed';
	celltyp=strip(extyp);
	if exstat=99 and exstatsp^='' then bmstat=strip(put(exstat,exstat.))||': '||strip(exstatsp);
		else if exstat^=. and  exstatsp='' then bmstat=strip(put(exstat,exstat.));
	if exlv=0 then lvinvol='No';
		else if exlv=1 then lvinvol='Yes';
	if exlvsz=99 and exlrblsp^='' then lvsize=strip(put(exlvsz,size.))||': '||strip(exlrblsp);
		else if exlvsz^=. and exlrblsp='' then lvsize=strip(put(exlvsz,size.));
	if exspln=0 then spinvol='No';
		else if exspln=1 then spinvol='Yes';
	if exsplnsz=99 and exsrblsp^='' then spsize=strip(put(exsplnsz,size.))||': '||strip(exsrblsp);
		else if exsplnsz^=. and exsrblsp='' then spsize=strip(put(exsplnsz,size.));
	keep subid visit visitnum tudtc bminvol celltyp bmstat lvinvol lvsize spinvol spsize;
run;

proc sort data=extra;by subid tudtc visitnum ; run;

data pdata.extra01(label='Extranodal Disease Assessment: Disease Assessment');
	retain subid visit tudtc bminvol celltyp bmstat lvinvol lvsize spinvol spsize;
	keep subid visit tudtc bminvol celltyp bmstat lvinvol lvsize spinvol spsize;
	set extra;
run;
