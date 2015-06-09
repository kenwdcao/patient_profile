
%include '_setup.sas';

data _null_;
	length dset $32;
	input dset :$ @@;
	if _n_=1 then call execute('%init');
	call execute('%insertdov('||dset||')');
	cards;
rd_frmdm rd_frmbmiwthx rd_frmfollow rd_frmsurvival_active rd_frmtarget1 rd_frmtarget2 rd_frmchem rd_frmchemuns
rd_frmdxa rd_frmecg rd_frmecog rd_frmfaact rd_frmfacitf rd_frmhema rd_frmhemauns rd_frmhgs
rd_frmhunger rd_frmkarnofsky rd_frmntarget1_active rd_frmntarget2_active rd_frmpe1 rd_frmpe2 rd_frmpe3
rd_frmtarget1_scttar1t_active rd_frmtarget2_scttar2t_active rd_frmtmrass rd_frmurin rd_frmurinuns rd_frmvs1
rd_frmvs2 rd_frmvs3 rd_frmchemuns_sctchemo_active
;
run;

proc sort data=_visit0 nodupkey; by subjectnumberstr visitmnemonic dov_c source; run;

data _visit1;
	set _visit0(rename=source=in_source);
		by subjectnumberstr visitmnemonic dov_c;
	length source $512;
	retain source;
	if first.dov_c then source=in_source;
	else source=strip(source)||', '||in_source;
	if last.dov_c;
	drop in_source;
run;

proc sort data=_visit1 out=_visit1_1; by subjectnumberstr dov_c visitmnemonic; where upcase(visitmnemonic) =  'SURVIVAL'; run;
proc sort data=_visit1 out=_visit1_2; by subjectnumberstr dov_c visitmnemonic; where upcase(visitmnemonic) ^= 'SURVIVAL'; run;

data _visit2_1;
	set _visit1_1;
	in_visitmnemonic=visitmnemonic;
	visitnum=98;
run;

*Ken on 2013/03/27: Rederive VISITNUM. Fix the visitnum of a scedueld visit;
data _visit2_2;
	set _visit1_2;
		by subjectnumberstr dov_c visitmnemonic;
	retain ordtumor orduns visitnum;
	*search key word WK, and get week number;
	if visitmnemonic='Day -14 to 0' then visitnum=0;
	retain __pid visitnum;
	if _n_=1 then do;
		__pid=prxparse('/WK\s*\d+/');
	end;
	call prxsubstr(__pid,upcase(visitmnemonic),__start,__len);
	if __start>0 and __len>0 then visitnum=input(strip(substr(visitmnemonic,__start+2,__len-2)),best.);
	if first.subjectnumberstr then 
	do;
		ordtumor=0; 
		orduns=0;
		if visitnum^=0 then visitnum=-1;
	end;
	if upcase(visitmnemonic)='UNS' then do;
		orduns=orduns+1;
		visitnum=visitnum+orduns*0.1;
	end;
	if upcase(visitmnemonic)='TUMOR' then do;
		ordtumor=ordtumor+1;
		visitnum=visitnum+ordtumor*0.1;
	end;
	in_visitmnemonic=visitmnemonic;
	if upcase(visitmnemonic)='UNS' then	visitmnemonic=strip(visitmnemonic)||' '||strip(put(orduns,best.));
	else if upcase(visitmnemonic)='TUMOR' then visitmnemonic=strip(visitmnemonic)||' '||strip(put(ordtumor,best.));
/*		else if upcase(visitmnemonic)='TUMOR' then visitmnemonic=strip(visitmnemonic)||' '||strip(put(ordtumor,best.));*/
/*	drop ordtumor orduns  __:;*/
run;

data _visit2;
	set _visit2_1 _visit2_2;
run;

proc sort data=_visit2 out=pdata._visitindex; by subjectnumberstr visitnum; run;


proc sql;
	create table pdata.firstdose as 
	select DISTINCT SUBJECTNUMBERSTR,input(min(ITMDRUGFIRSTDOSEDT_DTS),yymmdd10.) as fdosedt
	from source.RD_FRMDRUG_ACTIVE
	group by SUBJECTNUMBERSTR;
quit;
