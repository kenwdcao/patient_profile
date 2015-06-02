
%include '_setup.sas';

	* ---> Appendix 2: SAE discription;
data ae2;
	set source.RD_FRMAE_SCTAEENTRY_ACTIVE(rename=(ITMAESEQNUM=_ITMAESEQNUM));
	%adjustvalue(dsetlabel=Serious Adverse Events);
	*-> Modify Variable Label;
	attrib
	ITMAESEQNUM          	   label='AE Number'
	ITMAEDESCRIBE              label='Describe the event'
	ITMAETESTRESULTS           label='Relevant test results'
	ITMAEEVIDSUPP              label='Evidence supporting recovery return to baseline or description of new baseline'

	;
ITMAESEQNUM=ifc(_ITMAESEQNUM=.,'',put(_ITMAESEQNUM,best.));
if ITMAEEVENT ^='' and strip(ITMAESER)="itmAESerCmpCI";
run;

proc sort data=ae2 out=s_ae2; by SUBJECTNUMBERSTR ITMAESEQNUM; run;

proc transpose data=s_ae2 out=t_ae2(drop= _name_); 
	by SUBJECTNUMBERSTR ITMAESEQNUM;
	var ITMAEDESCRIBE ITMAETESTRESULTS ITMAEEVIDSUPP;
run;

data pdata.aeidx(label='Appendix 1: Serious Adverse Events');
retain SUBJECTNUMBERSTR ITMAESEQNUM _LABEL_ COL1; 
keep SUBJECTNUMBERSTR ITMAESEQNUM _LABEL_ COL1; 
	label
		_LABEL_='Item'
		COL1='Result'
		;
set t_ae2;
run;
