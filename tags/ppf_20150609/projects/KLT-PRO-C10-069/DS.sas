%INCLUDE "_setup.sas";
*<DS--------------------------------------------------------------------------------------------------------;
data ds0;
set source.ds;
	attrib
	subjid       label='Unique Subject Identifier'
	DSCOMPYN_    label='Completion of Event or Period'   length=$6
	DSSTDTC      label='Start Date'
	DSTERM       label='Reported Term'
	DSDECOD      label='Standardized Disposition#Term'
	DSCAT        label='Category for#Disposition Event'

	;
	if DSCOMPYN ='Y' then DSCOMPYN_='Yes'; else if DSCOMPYN='N' then DSCOMPYN_='No';
	if length(strip(DSSTDTC))=10 and DSSTDY^=. then DSSTDTC=strip(DSSTDTC)||"("||strip(ifc(DSSTDY=.,'',put(DSSTDY,best.)))||")";
	if DSTERM ^='';
run;


data pdata.ds(label='Disposition Event');
    retain  SUBJID DSSTDTC DSCOMPYN_ DSTERM DSDECOD EPOCH DSCAT DSDTHDTC DSTHO DSDTHAUT DSAUTDTC;
	keep   SUBJID DSSTDTC DSCOMPYN_ DSTERM DSDECOD EPOCH DSCAT DSDTHDTC DSTHO DSDTHAUT DSAUTDTC;
	set ds0;
run;
