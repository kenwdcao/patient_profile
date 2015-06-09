%include '_setup.sas';
**** Surgical History ****;
data sh1;
	length MHTERM $200;
	set source.sh;
	%formatDate(SHPRODTC);
	format _all_;
	label 
		SHPRODTC='Procedure Date'
		SHCOND='Reason for Procedure'
	;
	MHTERM=strip(upcase(SHPROC));
	if SHSGYN=1;
	keep SUBID SHPROC SHPRODTC SHCOND MHTERM ID;
run;
proc sort data=sh1;by SUBID SHPRODTC MHTERM;run;
data pdata.mh02(label='Surgical History');
	retain SUBID SHPROC SHPRODTC SHCOND __ID; 
	keep SUBID SHPROC SHPRODTC SHCOND __ID;
	set sh1(rename=ID=__ID);
run; 
