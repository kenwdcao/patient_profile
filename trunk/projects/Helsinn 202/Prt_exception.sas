
* -----> Special Report Definition List;

%macro prt_exception;

	%local text1;
	%local text2;
	%local text3;

	%if %upcase(&dset)=ECG %then %do;
		%let text1=%str(              Pre-Dose               );
		%let text2=%str(              Post-Dose 1            );
		%let text3=%str(        Single Measurement           );
		column ( 
			%if %upcase(&compare)=Y %then %str( q2type q2comment );
			__n  visitnum visitn visitdt crfstat perform
			("^{style [just=c fontweight=bold textdecoration=underline]&text3}" ecgtm2 ecgresult2 cs2)			
			("^{style [just=c fontweight=bold textdecoration=underline]&text1}" ecgtm ecgresult cs)
			("^{style [just=c fontweight=bold textdecoration=underline]&text2}" ecgtm1 ecgresult1 cs1)
		);

		define perform/ style(column)=[cellwidth=1.0in];
		define ecgresult/ style(column)=[just=c];
		define ecgresult2/ style(column)=[just=c];
		define cs/ style(header)=[just=c];
		define cs1/ style(header)=[just=c];
		define cs2/ style(header)=[just=c];
	%end;
	%else %if %upcase(&dset)=VSD %then %do;
		%let text1=%str(                 Pre-Dose                      );
		%let text2=%str(                 Post-Dose                     );
		column (
			%if %upcase(&compare)=Y %then %str( q2type q2comment );
			__n  visitnum visitn __ord crfname1 visitdt crfstat  
			("^{style [just=c fontweight=bold textdecoration=underline]&text1}" vsdtcm bp vshrc vstempc)
			("^{style [just=c fontweight=bold textdecoration=underline]&text2}"  vsdtcm1 bp1 vshrc1 vstempc1)
		);
		define vshrc/style(column)=[just=c];
		define vshrc1/style(column)=[just=c];
	%end;
	%else %if %upcase(&dset)=CLTC1 or %upcase(&dset)=CLTC2  %then %do;
		define visitn / style(column)=[width=1.5in];
	%end;
	%else %if %upcase(&dset)=CLTH %then %do;
		define visitn / style(column)=[width=1.1in];
		define visitdt / style(column)=[width=0.6in];
		define crfstat / style(column)=[width=0.5in just=c];
		define perform / style(column)=[width=0.7in];
	%end;
	%else %if %upcase(&dset)=DM %then %do;
		define visitn / style(column)=[width=1.2in];
		define visitdt / style(column)=[width=0.8in];
		define icdt / style(column)=[width=0.8in];
		define Race / style(column)=[width=1.2in];
	%end;
	%else %if %upcase(&dset)=CM %then %do;
		define crfstat / style(column)=[width=1.0in];
		define cmstdt /  style(column)=[width=0.9in];
		define cmendt /  style(column)=[width=0.9in];
		define cmae /  style(column)=[width=0.8in];
	%end;
	%else %if %upcase(&dset)=DH %then %do;
		define visitn / style(column)=[width=1.2in];
	%end;
	%else %if %upcase(&dset)=AE %then %do;
		define aestdtm / style(column)=[just=c];
		define aeendtm / style(column)=[just=c];
		define aerel / style(column)=[just=c];
		define aeser / style(column)=[just=c];
		define aeact / style(column)=[just=c];
		define aetrt / style(column)=[just=c];
		define aetrtm / style(column)=[just=c];
	%end;
	%else %if %upcase(&dset)=SD %then %do;
		define visitn / style(column)=[width=1.2in];
		define visitdt / style(column)=[cellwidth=0.8in];
		define crfstat / style(column)=[cellwidth=0.6in];
		define surinc / style(column)=[cellwidth=1.5in];
		define procal / style(column)=[cellwidth=1.5in];
		define postd / style(column)=[cellwidth=1.5in];
		define postl / style(column)=[cellwidth=1.5in];
		define postcol / style(column)=[cellwidth=1.5in];
	%end;
	%else %if %upcase(&dset)=VISITIDX %then %do;
		define visit / style(column)=[width=3.5in];
		define visit2 / style(column)=[cellwidth=2.5in];
	%end;
	%else %if %upcase(&dset)=CMTCHEM %then %do;
		define visitn / style(column)=[width=2.5in];
		define lbctests / style(column)=[width=3.0in];
		define lbccomm / style(column)=[cellwidth=3.5in];
	%end;
	%else %if %upcase(&dset)=CMTHEMA %then %do;
		define visitn / style(column)=[width=2.5in];
		define lbhtests / style(column)=[width=3.0in];
		define lbccomm / style(column)=[cellwidth=3.5in];
	%end;
	%else %if %upcase(&dset)=CMTURIN %then %do;
		define visitn / style(column)=[width=2.5in];
		define lbutests / style(column)=[width=3.0in];
		define lbccomm / style(column)=[cellwidth=3.5in];
	%end;
	%else %if %upcase(&dset)=REFRANGE %then %do;
		define item / style(column)=[width=2.5in just=l];
		define low / style(column)=[width=2.0in just=l];
		define high / style(column)=[cellwidth=2.0in just=l];
	%end;
	%else %if %upcase(&dset)=FIGURE %then %do;
		define figure / '' style(column)=[just=c];
	%end;

	*<!-- This part must be put in the end-->*;
	*->For all dataset;
	%local dsid;
	%local varnum;
	%local rc;

	%let dsid=%sysfunc(open(__prt));
	%let varnum=%sysfunc(varnum(&dsid,crfstat));
	%let rc=%sysfunc(close(&dsid));

	*->if CRFSTAT is first variable, then left align, otherwise center align;
	%if &varnum>1 %then %do;
		define crfstat/style(column)=[just=c];
	%end;

	%let dsid=%sysfunc(open(__prt));
	%let varnum=%sysfunc(varnum(&dsid,crfname));
	%let rc=%sysfunc(close(&dsid));

	%if &varnum>0 %then %do;
		define crfname/noprint;
	%end;

	%let dsid=%sysfunc(open(__prt));
	%let varnum=%sysfunc(varnum(&dsid,visitnum));
	%let rc=%sysfunc(close(&dsid));

	%if &varnum>0 %then %do;
		define visitnum/noprint;
	%end;
	***;


%mend prt_exception;
