/*
    Program Name: cm.sas
        @Author: Xiu Pan
        @Initial Date: 2014/08/18
*/
%include '_setup.sas';

data cm;
	set source.cm(rename=(cmdose=cmdose_ cmfreq=cmfreq_ cmroute=cmroute_ cmstdtc=cmstdtc_));
	format _all_;
	attrib
	name			   label='Medication Name'					length=$200
	cmdecod			label='Preferred Term'					length=$200
	cmstdtc			label='Start Date'							length=$19
	cmendtc			label='Stop Date'							length=$19
	cmindc			label='Indication'							length=$200
	cmdose			label='Dose'								length=$20
	cmdosu			label='Dose Units'							length=$60
	cmfreq			label='Frequency'							length=$100
	cmroute			label='Route'
	__sortkey													length=$200
	;

	length cmdecod $200;
	if index(m_pt1,'/')>0 and compress(scan(m_pt1,2,'/'),,'d')='' then cmdecod=strip(scan(m_pt1,1,'/'));
		else if index(m_pt1,'(')>0 then cmdecod=strip(scan(m_pt1,1,'('));
			else cmdecod=strip(m_pt1);
	cmdecod=prxchange('s/\t/ /',-1,cmdecod);
	/*ptname=strip(cmname)||'/'||strip(cmdecod);*/
	name=strip(cmname);
	%formatDate(cmstdtc_);
	%formatDate(cmenddtc);
	cmstdtc=cmstdtc_;
	if cmenddtc^='' then cmendtc=cmenddtc;
		else if cmong^=. then cmendtc='Ongoing';
	if cmind^=. and cmindot^='' then cmindc=strip(put(cmind,cmind.))||": "||strip(cmindot);
		else if cmind^=. then cmindc=strip(put(cmind,cmind.));
	if cmdose_^=. then cmdose=strip(put(cmdose_,best.));
	if cmunit=99 and cmunitsp^='' then cmdosu=strip(put(cmunit,cmunit.))||': '||strip(cmunitsp);
		else if cmunit^=. and cmunitsp='' then cmdosu=strip(put(cmunit,cmunit.));
	if cmfreq_=99 and cmfreqsp^='' then cmfreq=strip(put(cmfreq_,cmfreq.))||': '||strip(cmfreqsp);
		else if cmfreq_^=. and cmfreqsp='' then cmfreq=strip(put(cmfreq_,cmfreq.));
	if cmroute_=99 and cmroutsp^='' then cmroute=strip(put(cmroute_,cmroute.))||': '||strip(cmroutsp);
		else if cmroute_^=. and cmroutsp='' then cmroute=strip(put(cmroute_,cmroute.));
	__sortkey=lowcase(strip(name));
run;

proc sort data=cm;by subid cmstdtc __sortkey;run;

data pdata.cm(label='Concomitant Medication');
	retain subid name cmdecod cmstdtc cmendtc cmindc cmdose cmdosu cmfreq cmroute;
	keep subid name cmdecod cmstdtc cmendtc cmindc cmdose cmdosu cmfreq cmroute;
	set cm;
run;
