
%include '_setup.sas';

*<IE--------------------------------------------------------------------------------------------------------;
proc format;
	value $inc
	"2"="Documented histologic or cytologic diagnosis of American Joint Committee on Cancer (AJCC) Stage III or IV NSCLC. Stage III patients must have unresectable disease."
	"3"="With regard to chemotherapy and/or radiation therapy(Details please refer to page 32 of protocol HT-ANAM-302 AMENDMENT 1)"
	"8"="Adequate hepatic function, defined as AST and ALT levels =<5 × ULN"
	;

	value $exc
	"10"="Has known or symptomatic brain metastases"
	;
run;

data ie0;
	set source.RD_FRMINC_SCTINCENTRY_ACTIVE(rename=(ITMINCNOTMET=_ITMINCNOTMET));
	%adjustvalue(dsetlabel=Inclusion/Exclusion Criteria);
	%informatDate(DOV);
*-> Modify Variable Label;
attrib	
	A_DOV		label='Visit Date'
	ITMINCNOTMET   label='Inclusion criterion not met'  length=$200
	__sortkey1   length=$200
	;

	ITMINCNOTMET=put(_ITMINCNOTMET,$inc.);
	__sortkey1=lowcase(strip(ITMINCNOTMET));

	if _ITMINCNOTMET^='';
run;

data ie31;
retain &GlobalVars2 ITMINCNOTMET __sortkey1;
keep &GlobalVars2 ITMINCNOTMET __sortkey1;
set ie0;
run;

data ie1;
length ITMEXCMET $200;
	set source.RD_FRMEXC_SCTEXCENTRY_ACTIVE(rename=(ITMEXCMET=_ITMEXCMET));
	%adjustvalue(dsetlabel=Inclusion/Exclusion Criteria);
	%informatDate(DOV);
*-> Modify Variable Label;
attrib	
	A_DOV		label='Visit Date'
	ITMEXCMET   label='Exclusion criterion met'
	__sortkey2   length=$200

	;
	ITMEXCMET=put(_ITMEXCMET,$exc.);
	__sortkey2=lowcase(strip(ITMEXCMET));

	if _ITMEXCMET^='';
run;

data ie32;
retain &GlobalVars2 ITMEXCMET __sortkey2;
keep &GlobalVars2 ITMEXCMET __sortkey2;
set ie1;
run;

data ieall;
	set ie31 ie32;
run;
proc sort data=ieall; by SUBJECTNUMBERSTR __sortkey1 __sortkey2; run;

data pdata.ie(label='Inclusion/Exclusion Criteria');
retain &GlobalVars2 ITMINCNOTMET ITMEXCMET;
keep &GlobalVars2 ITMINCNOTMET ITMEXCMET;
set ieall;
run;
