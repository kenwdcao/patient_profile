
%include '_setup.sas';
option noquotelenmax;

*<IE--------------------------------------------------------------------------------------------------------;
proc format;
	value $exc
	"01"="Women who are pregnant or breast-feeding"
	"02"="Had major surgery (central venous access placement and tumor biopsies are not
considered major surgery) within 4 weeks prior to enrollment into the extension
study. Patients must be well recovered from acute effects of surgery prior to
screening. Patients should not have plans to undergo major surgical procedures
during the treatment period."
	"03"="Currently taking prescription medications intended to increase appetite or treat
weight loss; these include, but are not limited to, testosterone, androgenic
compounds, megestrol acetate, methylphenidate, and dronabinol"
	"04"="Patients unable to readily swallow oral tablets. Patients with severe
gastrointestinal disease (including esophagitis, gastritis, malabsorption, or
obstructive symptoms) or intractable or frequent vomiting are excluded."
	"05"="Has an active, uncontrolled infection"
	"06"="Has known or symptomatic brain metastases"
	"07"="Patients receiving strong CYP3A4 inhibitors (see Appendix VI)"
	"08"="Patients receiving tube feedings or parenteral nutrition (either total or partial).
Patients must have discontinued these treatments for at least 6 weeks prior to
Day 1, and throughout the study duration"	
	"09"="Other clinical diagnosis, ongoing or intercurrent illness that in the Investigator’s 
opinion would prevent the patient’s participation"	
	"10"="Patients actively receiving a concurrent investigational agent, other than 
Anamorelin HCl"
;

value $inc
	"01"="The patient has completed the Day 85 Visit in the original trial (Study
HT-ANAM-301 or HT-ANAM-302) and the Investigator considers the patient to
be appropriate to continue to receive an additional 12 weeks of study drug
administration. The patient must start dosing on the extension study within 5 days
of completing dosing on the original trial."
	"02"="Females and males at least 18 years of age"
	"03"="ECOG performance status =<2 (see Appendix I)"
	"04"="Estimated life expectancy of >4 months at the time of screening"
	"05"="If the patient is a woman of childbearing potential or a fertile man, he/she must
agree to use an effective form of contraception during the study and for 30 days
following the last dose of study drug (an effective form of contraception is
abstinence, a hormonal contraceptive, or a double-barrier method)."
	"06"="The patient must be willing and able to give signed informed consent and, in the 
opinion of the Investigator, to comply with the protocol tests and procedures."

	;
run;

data ie0;
length ITMINCNOTMET $200;
	set source.RD_FRMINC_SCTINCENTRY_ACTIVE(rename=ITMINCNOTMET=_ITMINCNOTMET);
	%adjustvalue(dsetlabel=Inclusion/Exclusion Criteria);
	%informatDate(DOV);
*-> Modify Variable Label;
attrib	
	A_DOV		label='Visit Date'
	ITMINCNOTMET   label='Inclusion criterion not met'  
	;

	ITMINCNOTMET=put(_ITMINCNOTMET,$inc.);
run;

data ie31;
retain &GlobalVars2 ITMINCNOTMET;
keep &GlobalVars2 ITMINCNOTMET;
set ie0;
run;

data ie1;
length ITMEXCMET $200;
	set source.RD_FRMEXC_SCTEXCENTRY_ACTIVE(rename=ITMEXCMET=_ITMEXCMET);
	%adjustvalue(dsetlabel=Inclusion/Exclusion Criteria);
	%informatDate(DOV);
*-> Modify Variable Label;
attrib	
	A_DOV		label='Visit Date'
	ITMEXCMET   label='Exclusion criterion met'

	;
	ITMEXCMET=put(_ITMEXCMET,$exc.);
run;

data ie32;
retain &GlobalVars2 ITMEXCMET;
keep &GlobalVars2 ITMEXCMET;
set ie1;
run;

data pdata.ie(label='Inclusion/Exclusion Criteria');
retain &GlobalVars2 ITMINCNOTMET ITMEXCMET;
keep &GlobalVars2 ITMINCNOTMET ITMEXCMET;
set ie31 ie32;
run;
