/*
    Program Name: tut.sas
        @Author: Xiu Pan
        @Initial Date: 2014/08/18
*/
%include '_setup.sas';

proc sql;
	create table tu as
	select a.*,b.ttyn, b.ttdate, b.ttdatec, b.ttsum,b.ttvis,b.ttvissp,b.id_tt,b.subid_tt
	from source.lmd as a full join source.tt(rename=(id=id_tt subid=subid_tt)) as b
	on a.subid=b.subid_tt and a.parent=b.id_tt
	;
quit;

data tu_01;
	set tu;
	format _all_;
	attrib
	tuloc  			label='Location'						length=$200
	analoc			label='Specific Site of Lesion'			length=$200
	tunum			label='Lesion'							length=$20
	tuldia			label='Longest Diameter#(mm)'			length=$20
	tudtc  			label='Date of Scan'					length=$19
	visit			label='Visit'							length=$60
	visitnum		label='Visit Number'					length=8
	method 			label='Method'							length=$100
	;
	if subid='' then subid=strip(subid_tt);
	if parent=. then parent=id_tt;
	%formatDate(TTDATEC);
	tudtc= ttdatec;
	if ttloc=28 then tuloc="Lymph Node: "||strip(ttln);
		else if ttloc=99 then tuloc="Other: "||strip(ttlocsp);
			else if ttloc^=. then tuloc=put(ttloc,loc.);
	analoc=strip(ttsite);
	if ttmeth=99 and ttmethsp^='' then method="Other: "||strip(ttmethsp);
		else if ttmeth^=. and ttmethsp='' then method=strip(put(ttmeth,method.));
	if ttnum^=. then tunum=strip(put(ttnum,best.));
	if ttldia^=. then tuldia=strip(put(ttldia,best.));
	if ttvis=99 and ttvissp^='' then visit=strip(put(strip(put(ttvis,best.)),$visit.))||'('||strip(ttvissp)||')';
		else if ttvis^=. and ttvissp='' then visit=strip(put(strip(put(ttvis,best.)),$visit.));
	visitnum=input(put(strip(put(ttvis,best.)),$vnum.),best.);
run;

proc sort data=tu_01 out=s_tu_01;by subid visitnum tudtc tunum;run;
/*Sum*/
proc sort data=s_tu_01 out=s_sum(keep=subid visit visitnum tudtc ttsum tunum ttnum tuldia) nodupkey; by subid visitnum visit tudtc ttnum; run;

data sum;
	set s_sum(where=(ttsum^=.));
	by subid visitnum visit tudtc ttnum;
	if last.visit;
	tunum='Sum';
	if ttnum^=. then ttnum=ttnum+1;
		else ttnum=1;
	tuldia=strip(put(ttsum,best.));
	ttldia=ttsum;
run;

data tuall;
	set s_tu_01 sum;
run;

proc sort data=tuall; by subid visitnum visit tudtc ttnum;run;

/*%Change from Baseline*/
data base;
	set tuall;
	where visit='Pre-Study';
	base=ttldia;
run;

proc sql;
	create table base_ as
	select a.*,b.base
	from tuall as a left join base as b
	on a.subid=b.subid and a.tunum=b.tunum
	;
quit;

proc sort data=base_; by subid ttnum tudtc visitnum;run;

data chg_base;
	set base_;
	if visit^='Pre-Study' then do;
		if base^=. and ttldia^=. then pchg=(ttldia-base)/base*100;
	end;
run;

/*%Change from Nadir*/
data nadir_01;
	set chg_base;
	by subid ttnum tudtc visitnum;
	nad1=lag(ttldia);
	if first.ttnum then nad1=ttldia;
run;

data nadir_02;
	set nadir_01;
	by subid ttnum tudtc visitnum;
	retain nad2;
	if first.ttnum then nad2=nad1;
		else if nad2>nad1 then nad2=nad1;
	if not first.ttnum then nadir=nad2;
run;

data chg_nadir;
	set nadir_02(rename=(pchg=pchg_));
	attrib
	base				label='Baseline Value'					length=8
	nadir				label='Nadir Value'						length=8
	pchg				label='%Change from Baseline'			length=$20
	pcnad				label='%Change from Nadir'				length=$20
	;
	if n(nadir,ttldia)=2 then pcnad=strip(put((ttldia-nadir)/nadir*100,10.1));
	if pchg_^=. then pchg=strip(put(pchg_,10.1));

run;

proc sort data=chg_nadir; by subid tudtc visitnum visit ttnum;run;

data pdata.tut(label='Target Tumor Assessment - Solid Tumor');	
	retain subid visit tudtc tuloc analoc tunum method tuldia /*base nadir*/ pchg pcnad;
	keep subid visit tudtc tuloc analoc tunum method tuldia /*base nadir*/ pchg pcnad;
	set chg_nadir;
run;
