%include '_setup.sas';

%macro concatDT(var=, dts1=, dts2=,newvar=);
if &var >'' and cmiss(&dts1,&dts2)<2 then &newvar= strip(scan(&var,1,','))||': '||strip(&dts1)||'/ '||strip(&dts2);
else if &var >'' then &newvar=&var;
%mend concatDT;
data ae1;
	set source.RD_FRMAE_SCTAEENTRY_ACTIVE(rename=(ITMAESEQNUM=_ITMAESEQNUM));
	%adjustvalue(dsetlabel= Serious Adverse Events);
	 %formatDate(ITMAEDEATHDT_DTS);
	%formatDate(ITMAEADMDT_DTS);
	%formatDate(ITMAEDISCHDT_DTS); 
	%formatDate(ITMAELASTDOSEDT_DTS);
	*-> Modify Variable Label;
	attrib
	ITMAESEQNUM          	   label='AE#Number'
	DEATHCI                    label='Fatal:Date of Death'
	ITMAEAUTPRF                label='Autopsy performed?'
	ITMAESERYES_CITMLIFETHR    label='Life threatening'
	ITMAEADMDT_DTS             label='Admission Date'
	ITMAEDISCHDT_DTS           label='Discharge Date'
	ITMAESERYES_CITMDISINC     label='Persistent or significant disability/incapacity'
	ITMAESERYES_CITMCONGANOM   label='Congenital anomaly/birth defect'
	ITMAESERYES_CITMIMPMEDEVT  label='Important medical event'
	ITMAEOTHPOSCAUS            label='Associated with a trial procedure?'
	ITMAEIMPROVED              label='Improve/disappear after stopping study med.'
	ITMAEREAPPEAR              label='Reappear/worsen after restarting study med.'
	ITMAELASTDOSEDT_DTS        label='Last dose date before SAE starting'

	;

	ITMAESEQNUM=ifc(_ITMAESEQNUM=.,'',put(_ITMAESEQNUM,best.));
	if ITMAESERYES_ITMAEDEATHCI ^='' then DEATHCI=strip(scan(ITMAESERYES_ITMAEDEATHCI,1,','))||': '||strip(ITMAEDEATHDT_DTS);

	%concatDT(var=ITMAESERYES_ITMAEHOSPCI, dts1=ITMAEADMDT_DTS, dts2=ITMAEDISCHDT_DTS,newvar=HOSPCI); 

	if ITMAEEVENT ^='' and strip(ITMAESER)="itmAESerCmpCI";

	if ITMAESERYES_CITMLIFETHR ^='' then ITMAESERYES_CITMLIFETHR='Y';
	if ITMAESERYES_CITMDISINC ^='' then ITMAESERYES_CITMDISINC='Y';
	if ITMAESERYES_CITMCONGANOM ^='' then ITMAESERYES_CITMCONGANOM='Y';
	if ITMAESERYES_CITMIMPMEDEVT ^='' then ITMAESERYES_CITMIMPMEDEVT='Y';
run;

data ae2;
	length __label $300;
	set ae1;
	if ITMAESER="No" then __label="Serious Adverse Events";
       else if ITMAESER ^="" then __label="Serious Adverse Events"||"^{style [foreground=&norangecolor] (See more details on Appendix 1)"||"}";
run;

proc sort data=ae2; by SUBJECTNUMBERSTR _ITMAESEQNUM;run;

data pdata.sae(label='Serious Adverse Events');
    retain  &globalvars3 __label ITMAESEQNUM DEATHCI ITMAEAUTPRF ITMAESERYES_CITMLIFETHR ITMAEADMDT_DTS 
			ITMAEDISCHDT_DTS ITMAESERYES_CITMDISINC ITMAESERYES_CITMCONGANOM ITMAESERYES_CITMIMPMEDEVT
			ITMAEOTHPOSCAUS ITMAEIMPROVED ITMAEREAPPEAR ITMAELASTDOSEDT_DTS;
	keep    &globalvars3 __label ITMAESEQNUM DEATHCI ITMAEAUTPRF ITMAESERYES_CITMLIFETHR ITMAEADMDT_DTS 
			ITMAEDISCHDT_DTS ITMAESERYES_CITMDISINC ITMAESERYES_CITMCONGANOM ITMAESERYES_CITMIMPMEDEVT
			ITMAEOTHPOSCAUS ITMAEIMPROVED ITMAEREAPPEAR ITMAELASTDOSEDT_DTS;
	set ae2;
run;
*----------------------------------------------------------------------------------------------------------->;
