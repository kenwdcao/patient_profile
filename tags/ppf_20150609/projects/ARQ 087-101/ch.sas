%include '_setup.sas';

proc sort data=source.ch out=s_ch nodupkey; by SUBID ID;run;

data ch;
	length CHTYPE $200 CHDGDTC $20 CHSTGE CHSTGD VISIT CHGRADE $200;
	keep SUBID VISIT CHTYPE CHTYPESP CHDGDTC CHGRADE CHSTGD CHSTGE;
	set s_ch(rename=(
	CHTYPE=CHTYPE_
	CHDGDTC=CHDGDTC_
	CHGRADE=CHGRADE_
	CHSTGE=CHSTGE_
	CHSTGD=CHSTGD_

	));
	VISIT='Pre-Study';
	if CHTYPE_^=. then CHTYPE=strip(put(CHTYPE_,chtype.));
	CHTYPESP=strip(CHTYPESP);
	if CHSTGE_=99 and CHSTGESP^='' then CHSTGE='Other: '||strip(CHSTGESP);
		else if CHSTGE_=99 then CHSTGE='Other';
			else if CHSTGE_^=. then CHSTGE=strip(put(CHSTGE_,chstgd.));
	if CHSTGD_=99 and CHSTGDSP^='' then CHSTGD='Other: '||strip(CHSTGDSP);
		else if CHSTGD_=99 then CHSTGD='Other';
			else if CHSTGD_^=. then CHSTGD=strip(put(CHSTGD_,chstgd.));
/*	if scan(strip(CHDGDTC_),1,'-')='****' and  scan(strip(CHDGDTC_),2,'-')='**' and  scan(strip(CHDGDTC_),3,'-')='**' then CHDGDTC="";*/
/*		else if scan(strip(CHDGDTC_),2,'-')='**' and  scan(strip(CHDGDTC_),3,'-')='**' then CHDGDTC=strip(scan(strip(CHDGDTC_),1,'-'));*/
/*			else if scan(strip(CHDGDTC_),3,'-')='**' then CHDGDTC=strip(substr(strip(CHDGDTC_),1,7));*/
/*				else if index(strip(CHDGDTC_),'*')=0 and CHDGDTC_^='' then CHDGDTC=strip(CHDGDTC_);*/
/*					else CHDGDTC="";*/
	CHDGDTC=CHDGDTC_;
	if CHGRADE_^=. then CHGRADE=strip(put(CHGRADE_,CHGRADE.));
	label CHTYPE='Type of Cancer'
		  VISIT='Visit'
		  CHTYPESP='Type of Cancer Specify'
		  CHDGDTC='Date of First Diagnosis'
		  CHGRADE='Histological Grade at Diagnosis'
		  CHSTGD='Tumor Stage at Diagnosis'
		  CHSTGE='Tumor Staging at Study Entry'
		  ;
run;

proc sort data=ch; by subid; run;

data pdata.ch(label='Current Cancer History');
	retain SUBID /*VISIT*/ CHTYPE CHTYPESP CHDGDTC CHGRADE CHSTGD CHSTGE;
	keep SUBID /*VISIT*/ CHTYPE CHTYPESP CHDGDTC CHGRADE CHSTGD CHSTGE;
	set ch;
run;

