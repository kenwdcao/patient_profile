/*
    Program Name: rslym.sas
        @Author: Xiu Pan
        @Initial Date: 2014/08/20
*/
%include '_setup.sas';

data rslym;
	set source.tul;
	where tulna=.;
	attrib
	rsyn				label='Tumor Response Performed'			length=$10
	nodmas				label='Nodal and Nodal Mass Response'		length=$200
	lspeen				label='Liver, Spleen Response'			    length=$200
	bmarow   			label='Bone Marrow Response'				length=$200
	mdisea   			label='Measurable Disease'					length=$20
	newdisea   			label='New Disease Site'					length=$20
	overass   			label='Overall Assessment'					length=$200
	comment   			label='Comment'								length=$200

	rsdtc  				label='Date of Assessment'					length=$19
	visit				label='Visit'								length=$60
	visitnum			label='Visit Number'						length=8
	;

	format _all_;
	if tulyn=0 then rsyn='No';
		else if tulyn=1 then rsyn='Yes';

	if tulnodal^=. and tulnodsp^='' then nodmas=strip(put(tulnodal,response.))||': '||strip(tulnodsp);
		else if tulnodal^=. and tulnodsp='' then nodmas=strip(put(tulnodal,response.));
	if tulls^=. and tulssp^='' then lspeen=strip(put(tulls,response.))||': '||strip(tulssp);
		else if tulls^=. and tulssp='' then lspeen=strip(put(tulls,response.));
	if tulbm^=. and tulbmsp^='' then bmarow=strip(put(tulbm,response.))||': '||strip(tulbmsp);
		else if tulbm^=. and tulbmsp='' then bmarow=strip(put(tulbm,response.));
	if tulmd^=. and tulmdsp^='' then mdisea=strip(put(tulmd,tulmd.))||': '||strip(tulmdsp);
		else if tulmd^=. and tulmdsp='' then mdisea=strip(put(tulmd,tulmd.));
	if tulns^=. and tulnssp^='' then newdisea=strip(put(tulns,tulns.))||': '||strip(tulnssp);
		else if tulns^=. and tulnssp='' then newdisea=strip(put(tulns,tulns.));
	if tuloall^=. then overass=strip(put(tuloall,tuloall.));
	comment=strip(tulcmt);

	%formatDate(TULDTC);
	rsdtc=strip(tuldtc);
	if tultyp=99 and tultypsp^='' then visit=strip(put(strip(put(tultyp,best.)),$visit.))||'('||strip(tultypsp)||')';
		else if tultyp^=. and tultypsp='' then visit=strip(put(strip(put(tultyp,best.)),$visit.));
	visitnum=input(put(strip(put(tultyp,best.)),$vnum.),best.);
run;

proc sort data=rslym; by subid rsdtc visitnum; run;

data pdata.rslym(label='Overall Tumor Assessment - Lymphoma');
	retain subid rsyn visit rsdtc nodmas lspeen bmarow mdisea newdisea overass comment;
	keep subid rsyn visit rsdtc nodmas lspeen bmarow mdisea newdisea overass comment;
	set rslym;
run;
