/*
	Program Name: EG.sas
		@Author: Ken Cao (yong.cao@q2bi.com_
		@Initial Date: 2013/05/07

	***********************************
	For EG data of KLT study
	***********************************

*/

%include "_setup.sas";

*filter;
data eg0;
	set source.eg;
	where not(egorres='' and egstat='' and egdtc='') and not (egorres='' and visit='UNSCHEDULED');
run;

data eg1;
	set eg0(rename=(egdtc=egdtc_ egorres=egorres_));
	length egdtc $40 egorres $200 egdone $200; 
	label egdtc = 'Date of ECG' egorres='Overall Impression' egdone='ECG Peformed?'
		egclinsg='ECG Clinical Significance'; 
	egdtc=egdtc_;
	egorres=propcase(egorres_);
	if egstat='' then egdone='Yes';
	else egdone='No, '||strip(lowcase(egreasnd));
	if egdy>. then egdtc=strip(egdtc)||' ('||strip(put(egdy,10.0))||")";
	visit=propcase(visit);
run;

data pdata.eg;
	retain subjid visit egdone egdtc egorres egclinsg ;
	keep subjid visit egdone egdtc egorres egclinsg;
	set eg1;
run;
