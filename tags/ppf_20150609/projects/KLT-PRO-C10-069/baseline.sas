
%include "_setup.sas";
*************************************************Study Identifiers, Subject  Demographics*********************************************************;
data ADSL_DM;
    set source.DM(rename=(RACE=in_RACE));
    rfstdt=INPUT(rfstdtc,yymmdd10.);
    brthdt=INPUT(brthdtc,yymmdd10.);
 	IF rfstdt^=. AND brthdt^=. THEN AGE=floor((rfstdt-brthdt + 1 )/365.25);
 	if AGE^=. then AGEU="YEARS";else AGEU='';
/*	if in_RACE = 'OTHER' and RACEO ^= '' then RACE = RACEO; else if in_RACE^= '' then RACE = in_RACE;*/
	if in_RACE = 'OTHER' and RACEO ^= '' then RACE = strip(in_RACE) || ': '||strip(RACEO); else if in_RACE^= '' then RACE = strip(in_RACE);
    KEEP STUDYID USUBJID SUBJID SITEID AGE AGEU SEX RACE ETHNIC;
RUN;

proc sort data=ADSL_DM; by subjid; run;


*************************************************Baseline Variables*********************************************************;
/*data psadt;*/
/*set source.dm;*/
/*keep subjid psadt usubjid;*/
/*run;*/

/* baseline BASEPSA*/
data BASEPSA;
	length BASEPSA $20;
	keep USUBJID BASEPSA subjid;
	set source.SC;
	where SCTESTCD='PSA';
	if SCORRES ^= '' then BASEPSA = strip(SCORRES);
run;

proc sort data=BASEPSA out=BASEPSA; by subjid; run;

/* baseline GLSNINI*/
data strata1 ;
     set source.sc;
     where sctestcd='GLSNSUM'; 
	 length GLSNINI $20;
     if SCORRES in ('5', '6', '3+4')  then GLSNINI='<=6, 3+4';
     else if SCORRES in ('8', '9', '10', '4+3') then GLSNINI='4+3, >=8'; 
	 keep usubjid SCORRES GLSNINI subjid;
	 rename SCORRES=GLEASON;
     run;

proc sort data=strata1 out=strata1; by subjid; run;

/*POI_715_Laboratory_Data_130318*/
proc sort data=source.POI_715_Laboratory_Data_130318 out=poi;
/*where visit="Screening";*/
where visit="Screening" and lborres ^='Cancelled';
by subjid LBTESTCD descending LBDTC;
run;


data poi;
set poi;
by subjid LBTESTCD descending LBDTC;
if first.LBTESTCD;
run;

proc sort data=poi;by subjid; run;

data BLTSTRON(rename=(LBORRES=BLTSTRON)) BLTESTF(rename=(LBORRES=BLTESTF)) BLESTRG(rename=(LBORRES=BLESTRG))
BLTLH(rename=(LBORRES=BLTLH)) BLTFSHC(rename=(LBORRES=BLTFSHC)) BLTTCRP(rename=(LBORRES=BLTTCRP))
BLCD4A(rename=(LBORRES=BLCD4A)) BLCD4P1(rename=(LBORRES=BLCD4P1)) BLCD8A(rename=(LBORRES=BLCD8A))
BLCD8P1(rename=(LBORRES=BLCD8P1)) BLNK2A(rename=(LBORRES=BLNK2A)) BLNK2P1(rename=(LBORRES=BLNK2P1));
length usubjid $40;
set poi(rename=(usubjid=in0_usubjid));
usubjid="PRO-C10-069-"||strip(in0_usubjid);
drop in0_usubjid;
keep usubjid LBORRES subjid;
if LBTESTCD = "TSTRON" then output BLTSTRON;
if LBTESTCD = "TESTF" then output BLTESTF;
if LBTESTCD = "ESTRG" then output BLESTRG;
if LBTESTCD = "TLH" then output BLTLH;
if LBTESTCD = "TFSHC" then output BLTFSHC;
if LBTESTCD = "TTCRP" then output BLTTCRP;
if LBTESTCD = "CD4A" then output BLCD4A;
if LBTESTCD = "CD4P1" then output BLCD4P1;
if LBTESTCD = "CD8A" then output BLCD8A;
if LBTESTCD = "CD8P1" then output BLCD8P1;
if LBTESTCD = "NK2A" then output BLNK2A;
if LBTESTCD = "NK2P1" then output BLNK2P1;
run;

data qs_;
	length ecog $60;
	set source.qs;
	where upcase(strip(visit))="SCREENING";
	keep subjid qsorres;
	rename qsorres=ecog;
	run;

proc sort data=qs_ out=qs; by subjid; run;

data vs_;
 length vsorres $60;
	set source.vs(rename=vsorres=vsorres_);
	where upcase(strip(visit))='SCREENING';
	vsorres=ifc(vsorres_=.,'',put(vsorres_,best.));
	if vsorres^='' then vsorres=strip(vsorres)||''||strip(vsorresu);
	if vsstat='NOT DONE' then vsorres='NA';
	keep subjid vsorres vsorresu vstestcd vstest visit vsdtc;
run;

proc sort data=vs_ out=vs; by subjid; run;


data pulse(rename=(vsorres=pulse)) diabp(rename=(vsorres=diabp)) sysbp(rename=vsorres=sysbp)
	resp(rename=vsorres=resp) height(rename=vsorres=height) weight(rename=vsorres=weight) temp(rename=vsorres=temp);
	set vs;
	keep subjid vsorres;
	if vstestcd='PULSE' then output pulse;
	if vstestcd='DIABP' then output diabp;
	if vstestcd='SYSBP' then output sysbp;
	if vstestcd='RESP' then output resp;
	if vstestcd='HEIGHT' then output height;
	if vstestcd='WEIGHT' then output weight;
	if vstestcd='TEMP' then output temp;
run;


data ADSL_2;
merge ADSL_DM /*psadt*/  BASEPSA strata1 BLTSTRON BLTESTF BLESTRG BLTLH BLTFSHC BLTTCRP BLCD4A BLCD4P1 BLCD8A 
      BLCD8P1 BLNK2A BLNK2P1 qs pulse diabp sysbp resp height weight temp;
by subjid;
run;

data  ADSL_3;
	set  ADSL_2(rename=(
	BLTSTRON=BASET
	BLTESTF=BASETF
	BLESTRG=BASEESTG
	BLTLH=BASELUHM
	BLTFSHC=BASEFSH
	BLTTCRP=BASECRP
/*	psadt=BASEPSDT*/

));
	length bp $60;
	if sysbp ^="NA" then bp=strip(compress(sysbp,,'a'))||' / '||strip(diabp);
		else if sysbp ="NA"  and diabp ^='NA' then bp=strip(sysbp)||' / '||strip(diabp);
		else if sysbp ="NA"  and diabp ='NA' then bp="NA";

	keep STUDYID USUBJID SUBJID 
	     GLEASON GLSNINI BASET BASETF BASEESTG BASELUHM BASEFSH
		BASECRP /*BASEPSDT*/ BLCD4A BLCD4P1 BLCD8A BLCD8P1 BLNK2A BLNK2P1 
		ecog pulse bp resp height weight temp
;
run;

data adsl_4;
	length gls lbbio01 lbcbc01 ecog vs $200;
	set adsl_3(rename=(ecog=ecog_));
	gls="^{style [fontweight=bold]Gleason Score: }"||"Initial Gleason Score: "||strip(GLSNINI)||"      Gleason Score Sum: "||strip(GLEASON);
	lbbio01="^{style [fontweight=bold]Biomarkers: }"||"Testosterone: "||strip(BASET)||"      Testosterone(Free): "||strip(BASETF)||"      Estrogens(Total): "
	      ||strip(BASEESTG)||"      Luteinizing Hormone: "||strip(BASELUHM)||"      FSH: "||strip(BASEFSH)||"      CRP: "||strip(BASECRP);
	lbcbc01="^{style [fontweight=bold]CBC w/Differential: }"||"CD4 Absolute: "||strip(BLCD4A)||'      %CD3+/CD4+: '||strip(BLCD4P1)||"      CD8 Absolute: "
			||strip(BLCD8A)||'      %CD3+/CD8+: '||strip(BLCD8P1)||"      CD16,56 Absolute: "||strip(BLNK2A)||'      %CD3-/CD16+,CD56+: '
			||strip(BLNK2P1);

	ecog="^{style [fontweight=bold]Ecog Performance Status: }"||strip(ecog_);
	vs="^{style [fontweight=bold]Vital Signs: }"||"Pulse: "||strip(pulse)||"      Sysbp/Diabp: "||strip(bp)||"      Respiratory Rate: "||strip(resp)
		||"      Height: "||strip(weight)||"      Weight: "||strip(weight)||"      Temperature: "||strip(temp);
	keep SUBJID gls lbbio01  lbcbc01 ecog vs;
run;

proc sort data=adsl_4 out=adsl;by subjid ;run;

proc transpose data =adsl out=baseline(rename=(_name_=test col1=orres));
by subjid;
var gls lbbio01  lbcbc01 ecog vs;
run;

data pdata.baseline(label='Baseline Characteristics');
	set baseline;
run;
