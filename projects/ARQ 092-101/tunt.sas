/*
    Program Name: tunt.sas
        @Author: Xiu Pan
        @Initial Date: 2014/08/19
*/
%include '_setup.sas';

proc sql;
	create table tunt as
	select a.*,b.ntyn,b.ntnone,b.ntsch,b.nttyp,b.nttypsp,b.ntdtc,b.id_tt,b.subid_tt
	from source.lnmd as a full join source.nt(rename=(id=id_tt subid=subid_tt)) as b
	on a.subid=b.subid_tt and a.parent=b.id_tt
	;
quit;

data tunt_01;
	set tunt;
	format _all_;
	attrib
	tuloc  			label='Location'								length=$200
	analoc			label='Specific Site of Lesion'			length=$200
	tunum			label='Lesion'										length=$20
	tudtc  			label='Date of Scan'						length=$19
	visit			label='Visit'										length=$60
	visitnum		label='Visit Number'							length=8
	method 			label='Method'									length=$100
	;
	if subid='' then subid=strip(subid_tt);
	if parent=. then parent=id_tt;
	%formatDate(NTDTC);
	tudtc=ntdtc;
	if ntloc=28 then tuloc="Lymph Node: "||strip(ntlymloc);
		else if ntloc=99 then tuloc="Other: "||strip(ntlocsp);
			else if ntloc^=. then tuloc=put(ntloc,loc.);
	analoc=strip(ntsite);
	if ntmeth=99 and ntmethsp^='' then method="Other: "||strip(ntmethsp);
		else if ntmeth^=. and ntmethsp='' then method=strip(put(ntmeth,method.));
	if ntnum^=. then tunum=strip(put(ntnum,best.));
	if nttyp=99 and nttypsp^='' then visit=strip(put(strip(put(nttyp,best.)),$visit.))||'('||strip(nttypsp)||')';
		else if nttyp^=. and nttypsp='' then visit=strip(put(strip(put(nttyp,best.)),$visit.));
	visitnum=input(put(strip(put(nttyp,best.)),$vnum.),best.);
run;

proc sort data=tunt_01 out=s_tunt_01;by subid visitnum tudtc tunum;run;

data tunt_02;
	length asmt $60;
	set s_tunt_01;
	if ntasmt=1 then asmt='Present';
		else if ntasmt=2 then asmt='Absent';
			else if ntasmt=3 then asmt='New Lesion';
				else if ntasmt=4 then asmt='Unequivocal Progression';
	if asmt='' and ntnone^=. then asmt='None Present';
run;

proc sort data=tunt_02; by subid tudtc visitnum visit ntnum; run;

data pdata.tunt(label='Non-Target Tumor Assessment - Solid Tumor');
	retain subid visit tudtc tuloc analoc tunum method asmt;
	keep subid visit tudtc tuloc analoc tunum method asmt;
	label asmt='Assessment';
	set tunt_02;
run;
