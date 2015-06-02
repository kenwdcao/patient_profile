/*
    Program Name: tulym.sas
        @Author: Xiu Pan
        @Initial Date: 2014/08/20
*/
%include '_setup.sas';

proc sql;
	create table tulym as
	select a.*,b.tlna,b.tlyn,b.tlvis,b.tlvissp,b.tldtc,b.tlnodes,b.tlndms,b.tlspd,b.tladdl,b.tlndinc,b.tlincsp,b.id_tt,b.subid_tt
	from source.tlad as a full join source.tl(rename=(id=id_tt subid=subid_tt)) as b
	on a.subid=b.subid_tt and a.parent=b.id_tt
	;
quit;

data tulym_01;
	set tulym(rename=(tlspd=tlspd_));
	where tlna=.;
	format _all_;
	attrib
	tuloc  			label='Location'							length=$200
	tunum			label='Lesion'								length=$20
	tuldia			label='Longest Diameter#(mm)'				length=$20
	tudtc  			label='Date of Scan'						length=$19
	visit			label='Visit'								length=$60
	visitnum		label='Visit Number'						length=8
	method 			label='Method'								length=$100
	tuperdia		label='Perpendicular Diameter#(mm)'			length=$20
	tuprodia		label='Product of Diameters#(mm2)'			length=$20
	petores			label='PET results'							length=$100
	tlnode			label='Number of Measurable Nodes'			length=$20
	tlmass			label='Number of Measurable Nodal Masses'	length=$20
	tlspd			label='SPD#(mm2)'							length=$20
	tladd			label='Additional Nodes?'					length=$20
	tlinc			label='increase in size?'					length=$20

	;
	if subid='' then subid=strip(subid_tt);
	if parent=. then parent=id_tt;
	%formatDate(TLDTC);
	tudtc= tldtc;
	tuloc=strip(tlloc);
	if tlmod=99 and tlmodsp^='' then method="Other: "||strip(tlmodsp);
		else if tlmod^=. and tlmodsp='' then method=strip(put(tlmod,tlmod.));
	if tllnum^=. then tunum=strip(put(tllnum,best.));
	if tlld^=. then tuldia=strip(put(tlld,best.));
	if tlpd^=. then tuperdia=strip(put(tlpd,best.));
	if tlpod^=. then tuprodia=strip(put(tlpod,best.));
	if tlpet=99 and tlpetsp^='' then petores="Other: "||strip(tlpetsp);
		else if tlpet^=. and tlpetsp='' then petores=strip(put(tlpet,tlpet.));
	if tlvis=99 and tlvissp^='' then visit=strip(put(strip(put(tlvis,best.)),$visit.))||'('||strip(tlvissp)||')';
		else if tlvis^=. and tlvissp='' then visit=strip(put(strip(put(tlvis,best.)),$visit.));
	visitnum=input(put(strip(put(tlvis,best.)),$vnum.),best.);
	if tlnodes^=. then tlnode=strip(put(tlnodes,best.));
	if tlndms^=. then tlmass=strip(put(tlndms,best.));
	if tlspd_^=. then tlspd=strip(put(tlspd_,best.));
	if tladdl=0 then tladd='No';
		else if tladdl=1 then tladd='Yes';
	if tlndinc=0 then tlinc='No';
		else if tlndinc=1 then tlinc='Yes';
			else if tlndinc=99 and tlincsp='' then tlinc='Other';
				else if tlndinc=99 and tlincsp^='' then tlinc='Other: '||strip(tlincsp);
	keep subid tudtc tuloc method tunum tuldia tuperdia tuprodia petores visit visitnum tlnode tlmass
		tlspd tladd tlinc tllnum tlspd_;
run;

proc sort data=tulym_01 out=s_tulym_01;by subid tudtc visitnum tunum;run;

/*%Change from Baseline for PSD*/
data base;
	set s_tulym_01;
	where visit='Pre-Study';
	base=tlspd_;
run;

proc sql;
	create table base_ as
	select a.*,b.base
	from s_tulym_01 as a left join base as b
	on a.subid=b.subid and a.tunum=b.tunum
	;
quit;

proc sort data=base_; by subid tllnum tudtc visitnum;run;

data chg_base;
	set base_;
	if visit^='Pre-Study' then do;
		if base^=. and tlspd_^=. then pchg=(tlspd_-base)/base*100;
	end;
run;

/*%Change/Change from Nadir for PSD*/
data nadir_01;
	set chg_base;
	by subid tllnum tudtc visitnum ;
	nad1=lag(tlspd_);
	if first.tllnum then nad1=tlspd_;
run;

data nadir_02;
	set nadir_01;
	by subid tllnum tudtc visitnum ;
	retain nad2;
	if first.tllnum then nad2=nad1;
		else if nad2>nad1 then nad2=nad1;
	if not first.tllnum then nadir=nad2;
run;

data chg_nadir;
	set nadir_02(rename=(pchg=pchg_));
	attrib
	base				label='Baseline Value'					length=8
	nadir				label='Nadir Value'						length=8
	pchg				label='%Change from Baseline for SPD'	length=$20
	pcnad				label='%Change from Nadir for SPD'		length=$20
	;
	if n(nadir,tlspd_)=2 then pcnad=strip(put((tlspd_-nadir)/nadir*100,10.1));
	if pchg_^=. then pchg=strip(put(pchg_,10.1));

run;

proc sort data=chg_nadir; by subid visitnum visit tudtc tllnum;run;

/*SPD*/
proc sort data=s_tulym_01 out=s_spd(keep=subid visit visitnum tudtc tlspd_ tunum tllnum) nodupkey; by subid visitnum visit tudtc tllnum; run;

data spd;
	set s_spd;
	by subid visitnum visit tudtc tllnum;
	if last.visit;
/*	tunum='SPD: '||strip(put(tlspd_,best.));*/

	tunum = 'SPD';
	TUPRODIA = strip(put(tlspd_,best.));

	if tllnum^=. then tllnum=tllnum+1;
		else tllnum=1;
run;

************;
proc sort data=chg_nadir out=spd_01(keep=subid pchg pcnad visit visitnum) nodupkey; by subid visitnum;run;

proc sql;
	create table spd_02 as
	select a.*,b.pchg,b.pcnad
	from spd as a left join spd_01 as b
	on a.subid=b.subid and a.visit=b.visit
	;
quit;

data tuall;
	set chg_nadir(drop=pchg pcnad) spd_02;
run;

proc sort data=tuall;by subid tudtc visitnum visit tllnum;run;

data pdata.tulym(label='Node and Nodal Mass Assessment - Lymphoma');	
	retain subid visit tudtc tuloc tunum method tuldia tuperdia tuprodia petores /*tlnode tlmass tladd tlinc*/ pchg pcnad /*base nadir*/;
	keep subid visit tudtc tuloc tunum method tuldia tuperdia tuprodia petores /*tlnode tlmass tladd tlinc*/ pchg pcnad /*base nadir*/;
	set tuall;
run;
