%include '_setup.sas';
**** Medical History ****;
data mh1;
	length MHTERM_ $200;
	set source.mh;
	%formatDate(MHONDTC);
	%formatDate(MHENDDTC);
	format _all_;
	label 
		MHTERM='Event/Diagnosis'
		MHONDTC='Start Date'
		MHENRF='Ongoing'
		MHENDDTC='Stop Date'
	;
	if MHCONT=1 then MHENRF='Yes';
	if mhyn=1;
	MHTERM_=strip(upcase(MHTERM));
	keep SUBID ID MHTERM MHTERM_ MHONDTC MHENDDTC MHENRF;
run;
proc sort data=mh1;by SUBID MHONDTC MHTERM_;run;
data pdata.mh(label='Medical History');
	retain SUBID MHTERM MHONDTC MHENDDTC MHENRF __ID; 
	keep SUBID MHTERM MHONDTC MHENDDTC MHENRF __ID;
	set mh1(rename=(ID=__ID));
run; 
