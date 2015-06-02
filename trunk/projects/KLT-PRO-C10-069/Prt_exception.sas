
* -----> Special Report Definition List;

%macro prt_exception;

	%local text1;
	%local text2;
	%local text3;


	%if %upcase(&dset)=RD %then %do;
		%let text1=%str(                             Radiological Test                             );
		%let text2=%str(                    Bone Scan                    );
		column ( 
			%if %upcase(&compare)=Y %then %str( q2type q2comment );
			__n A_VISIT		
			("^{style [just=c fontweight=bold textdecoration=underline]&text1}" RDDTC RDTEST rdorres)
			("^{style [just=c fontweight=bold textdecoration=underline]&text2}" rddtc_ rdorres1)
		)__:;
		define A_VISIT / style(column)=[width=1.5in];
		define RDDTC / 'Date  Performed#(Study Day)' style(column)=[width=1.8in just=c] style(header)=[just=c]; 
		define RDTEST / style(column)=[width=1.8in just=c] style(header)=[just=c];
		define rdorres / style(column)=[width=1.5in just=c] style(header)=[just=c];
		define rddtc_ / 'Date  Performed#(Study Day)' style(column)=[width=1.8in just=c] style(header)=[just=c];
		define rdorres1 / style(column)=[width=1.8in just=c] style(header)=[just=c];
	%end;

	%else %if %upcase(&dset)=LBBI %then %do;
		define LBTEST / ' ';
	%end;	

	%else %if %upcase(&dset)=LBCBC %then %do;
		define LBTEST / ' ';
	%end;

	%else %if %upcase(&dset)=LBSCHEM %then %do;
		define LBTEST / ' ';
	%end;
	
	%else %if %upcase(&dset)=REFRANGE %then %do;
		define item / style(column)=[width=3in];
		define low / style(column)=[width=3.3in just=c] style(header)=[just=c];
		define high / style(column)=[width=3.3in just=c] style(header)=[just=c];
	%end;

	%else %if %upcase(&dset)=CK %then %do;
		define CKTEST / ' ';
		define CKTEST / style(header)=[width=3.2in] style(column)=[width=3.2in];
		define V_: / style(header)=[just=c width=0.5in] style(column)=[just=c width=0.5in];

	%end;	

	%else %if %upcase(&dset)=DM %then %do;
		define PSARES / style(header)=[just=c] style(column)=[just=c];
		define PSADT / style(header)=[just=c] style(column)=[just=c];
		define PSADTRES / style(header)=[just=c] style(column)=[just=c];

	%end;

	%else %if %upcase(&dset)=DP %then %do;
		define DPTEST / ' ';
		define DPTEST / style(header)=[width=5.0in] style(column)=[width=5.0in];
		define V_: / style(header)=[width=0.9in] style(column)=[width=0.9in];
	%end;

		
	%else %if %upcase(&dset)=AE %then %do;
		define AEDECOD / noprint;
		define AEBODSYS / noprint;
		define AETOXGRC / style(column)=[just=c];
		define AESEQ / style(header)=[just=c] style(column)=[just=c];

	%end;	

		%else %if %upcase(&dset)=SAE %then %do;
		define AESEQ / style(header)=[width=1.0in just=c] style(column)=[width=1.0in just=c];
		define AETERM / style(header)=[width=2.2in] style(column)=[width=2.2in];
		define AESCONG_ / style(header)=[width=1.0in just=c] style(column)=[width=1.0in just=c];
		define AESDISAB_ / style(header)=[width=1.0in just=c] style(column)=[width=1.0in just=c];
		define AESDTH_ / style(header)=[width=1.0in just=c] style(column)=[width=1.0in just=c];
		define AESHOSP_ / style(header)=[width=1.3in just=c] style(column)=[width=1.3in just=c];
		define AESLIFE_ / style(header)=[width=1.3in just=c] style(column)=[width=1.3in just=c];
		define AESMIE_/ style(header)=[width=1.6in just=c] style(column)=[width=1.6in just=c];

	%end;



	%else %if %upcase(&dset)=CM %then %do;
		define CMDECOD / noprint;
		define CMCLAS / noprint;
		define cmspid / noprint;
	%end;

		%else %if %upcase(&dset)=DA %then %do;
		define A_VISIT / style(column)=[width=0.7in] style(header)=[width=0.7in];
		define DSDTC / style(column)=[width=1.0in] style(header)=[width=1.0in];
		define REDTC / style(column)=[width=1.0in] style(header)=[width=1.0in];
		define CAPSU / style(column)=[just=c width=1.2in] style(header)=[just=c width=1.2in];
		define COMP / style(column)=[just=c width=1.0in] style(header)=[just=c width=1.0in];
		define COMMENT / style(header)=[width=2.0in] style(column)=[width=2.0in];
		define LOTNUM / style(header)=[width=1.0in just=c] style(column)=[width=1.0in just=c];
		define REGIMEN / style(column)=[just=c width=0.7in] style(header)=[just=c width=0.7in];
		define DOSEMOD / style(column)=[just=c width=1.2in] style(header)=[just=c width=1.2in];
		define NEWREG / style(column)=[just=c width=0.7in] style(header)=[just=c width=0.7in];

	%end;

	%else %if %upcase(&dset)=NARRATIVE %then %do;
		define VISIT / style(column)=[width=1.0in];
		define EVENTY / style(column)=[width=1.5in];
		define EVENT / style(column)=[width=2.3in];
		define DATE / style(column)=[width=1.2in];
		define NOTE / style(column)=[width=4.2in];

	%end;

	%else %if %upcase(&dset)=BASELINE %then %do;
		define test / noprint;
		define orres / '';
	%end;


	%else %if %upcase(&dset)=OLEIE %then %do;
		define A_VISIT / style(column)=[width=1.5in];
		define OLEPSAPROG1 / style(column)=[width=2.5in just=c] style(header)=[just=c];
		define OLEMETADIS1 / style(column)=[width=3in just=c] style(header)=[just=c];
		define OLESPNAPRV1 / style(column)=[width=1.5in just=c] style(header)=[just=c];
		define OLEENROLDTC / style(column)=[width=1.5in just=c] style(header)=[just=c];
	%end;

	%else %if %upcase(&dset)=EG %then %do;
		define VISIT / style(column)=[width=1.5in];
		define EGDONE / style(column)=[width=3.5in just=c] style(header)=[just=c];
		define EGDTC / 'Date of ECG#(Study Day)' style(column)=[width=1.5in];
		define EGORRES / style(column)=[width=2in];
		define EGCLINSG / style(column)=[width=1.5in];
	%end;

	%else %if %upcase(&dset)=PE %then %do;
		define A_VISIT / style(column)=[width=1.2in];
		define pedtc /  style(column)=[width=2.5in just=c] style(header)=[just=c];
		define peorres / style(column)=[width=2.5in just=c] style(header)=[just=c];
		define NULL / ' ' style(column)=[width=0.5in];
		define peorres1 / style(column)=[width=3.5in] ;
	%end;

	%else %if %upcase(&dset)=MH %then %do;
		define MHTERM / style(column)=[width=2in];
		define MHDECOD / style(column)=[width=2in];
		define MHBODSYS / style(column)=[width=2.7in];
		define MHPRESP / noprint;
		define MHSTDTC / style(column)=[width=1in];
		define MHENDTC / style(column)=[width=1in];
		define MHENRF / style(column)=[width=1in];
	%end;

	%else %if %upcase(&dset)=PPR %then %do;
		define MHTERM / style(column)=[width=4in];
		define MHSITE / style(column)=[width=1.5in];
		define MHINTENT / style(column)=[width=1.5in];
		define MHSTDTC / style(column)=[width=1.5in];
		define MHENDTC / style(column)=[width=1.5in];
	%end;

	%else %if %upcase(&dset)=PPS %then %do;
		define MHTERM / style(column)=[width=4in];
		define MHINTENT / style(column)=[width=3in];
		define MHSTDTC / style(column)=[width=3in];
	%end;

	%else %if %upcase(&dset)=PPT %then %do;
		define MHTERM / style(column)=[width=3in just=c] style(header)=[just=c];
		define MHSPID / style(column)=[width=1.5in just=c] style(header)=[just=c];
		define MHSTDTC / style(column)=[width=1.8in];
		define MHENDTC / style(column)=[width=1.8in];
		define MHENRF / style(column)=[width=2in];
	%end;

	%else %if %upcase(&dset)=VS %then %do;
		define VSTEST / ' ';
	%end;

	%else %if %upcase(&dset)=QS %then %do;
		define QSTEST / ' ';
	%end;

	%else %if %upcase(&dset)=PSADT %then %do;
		define GRAPH / ' ' style(column)=[just=c];
	%end;
	
	%else %if %upcase(&dset)=IE %then %do;
		define ELIG01 / style(column)=[just=c] style(header)=[just=c];
		define CRITERION / style(column)=[just=c] style(header)=[just=c];
		define WAIVER / style(column)=[just=c] style(header)=[just=c];
		define ELIG02 / style(column)=[just=c] style(header)=[just=c];
		define SPONSOR / style(column)=[just=c] style(header)=[just=c];
	%end;

	
%mend prt_exception;
