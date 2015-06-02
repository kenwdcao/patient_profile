/*
	For safety patient profile of ARQ 092-101. Expousre.
*/

%include '_setup.sas';

proc sql;
	create table sd0 as
	select subid,
		sdstdtc,
		sddosst,
		sdfreq,
		sdfreqsp,
		sdenddtc,
		sdmod,
		sdmodify,
		sdmodsp,
		sdhdrn,
		sdhdrnsp
	from source.sd
	where subid in (select distinct subid from source.ae);
quit;

data sd;
	set sd0;
	keep subid sddosst sdstdtc sdenddtc freq sdmodyn exmodify exhdrsn;
	attrib
/*		exdtc      length=$100     label='Start Date(DY)/Frequency#End Date(DY)'*/
		freq       length=$200     label='Starting Dose Frequency'
		exmodify   length=$200     label='Type of Dose Modification'
		exhdrsn    length=$200     label='Dose Modify Reason'
/*		sdmodyn  length = $1      label = 'Was dose interrupted/modified during this period'*/
		sdmodyn  length = $10     label = 'Was Dose Interrupted/Modified During this Period'
		exdose   length=$200    label ='Starting Dose'
	;
	length exstdtc exendtc $20;
	exstdtc=sdstdtc;
	exendtc=sdenddtc;
/*	freq=coalescec(sdfreqsp,ifc(sdfreq>.,put(sdfreq,sdfreq.),''));*/
	if SDFREQ=99 then do;
		if sdfreqsp^='' then freq='Other: '||strip(sdfreqsp);
			else freq='Other';
	end;
		else if SDFREQ^=. then freq=strip(put(sdfreq,sdfreq.));
/*	exdtc=strip(exstdtc)||' '||strip(freq)||"&escapechar{newline}"||strip(exendtc);*/
/*	exmodify=coalescec(sdmodsp,ifc(sdmodify>.,put(sdmodify,sdmodify.),''));*/
	if sdmodify=99 then do;
		if sdmodsp^='' then exmodify='Other: '||strip(sdmodsp);
			else exmodify='Other';
	end;
		else if sdmodify^=. then exmodify=strip(put(sdmodify,sdmodify.));
/*	exhdrsn=coalescec(sdhdrnsp,ifc(sdhdrn>.,put(sdhdrn,sdhdrn.),''));*/
	if sdhdrn=99 then do;
		if sdhdrnsp^='' then exhdrsn='Other: '||strip(sdhdrnsp);
			else exhdrsn='Other';
	end;
		else if sdhdrn^=. then exhdrsn=strip(put(sdhdrn,sdmodify.));	
	if sddosst^=. then exdose = strip(put(sddosst,best.));
/*	if sdmod = 0 then sdmodyn = 'N'; else if sdmod =1 then sdmodyn = 'Y';*/
	if sdmod = 0 then sdmodyn = 'No'; else if sdmod =1 then sdmodyn = 'Yes';
	label
		sdstdtc    = 'Date of Dosing Start'
		sdenddtc   = 'Date of Last Dose This Period'

	;
run;

proc sort data=sd; by SUBID sdstdtc;run;

data pdata.sd(label='Exposure');
	retain subid sdstdtc SDDOSST freq sdenddtc sdmodyn exmodify exhdrsn;;
	keep subid sdstdtc SDDOSST freq sdenddtc sdmodyn exmodify exhdrsn;;
	set sd;
run;

