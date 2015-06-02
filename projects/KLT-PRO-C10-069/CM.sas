%INCLUDE "_setup.sas";

*<CM--------------------------------------------------------------------------------------------------------;

data cm0;
set source.cm(rename=(CMAE=CMAE_));

	attrib
 	SUBJID    label='Unique Subject Identifier' 
	CMDOSE_   label='Dose'  length=$20
	CMTRT     label='Reported Name'  
	CMAE      label='Related Adverse#Event Number' length=$300
	CMROUTE   label='Route'
	CMSTDTC   label='Start Date#(Study Day)'
	CMENDTC   label='End Date#(Study Day)'
	CMSTRF    label='Start Reference'
	CMENRF    label='End Reference'
	CMDOSE_   label='Dose per#Administration'

	;

	if CMAEREL ^='' then CMAE=CMAEREL;
	CMDOSE_=ifc(CMDOSE=.,'',put(CMDOSE,best.));

	if CMFRQOTH^='' then CMDOSFRQ=propcase(strip(CMDOSFRQ))||": "||strip(CMFRQOTH);
		else if CMDOSFRQ ^='' then CMDOSFRQ=propcase(strip(CMDOSFRQ));

	if CMROUTEO ^='' then CMROUTE=strip(CMROUTE)||": "||strip(CMROUTEO);

	if length(strip(CMENDTC)) =10 then CMENDTC=strip(CMENDTC)||"("|| strip(ifc(CMENDY=.,'',put(CMENDY,best.)))||")";
	if length(strip(CMSTDTC)) =10 then CMSTDTC=strip(CMSTDTC)||"("|| strip(ifc(CMSTDY=.,'',put(CMSTDY,best.)))||")";

	CMSTRF=propcase(strip(CMSTRF));
	CMENRF=propcase(strip(CMENRF));

	if index(CMAE_,"AE")>0 then CMAE="^{style [url='#dset20' linkcolor=white foreground=blue textdecoration=underline]"||strip(CMAE_)||"}";

	if CMTRT ^='';

run;

data pdata.cm(label='Concomitant Medication');
    retain  SUBJID CMSPID CMTRT CMDECOD CMCLAS CMINDC CMAE CMDOSE_ CMDOSU CMDOSFRQ CMROUTE CMSTDTC CMENDTC CMSTRF CMENRF;
	keep  SUBJID CMSPID CMTRT CMDECOD CMCLAS CMINDC CMAE CMDOSE_ CMDOSU CMDOSFRQ CMROUTE CMSTDTC CMENDTC CMSTRF CMENRF;
	set cm0;
run;


