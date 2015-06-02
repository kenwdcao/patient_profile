
* -----> Special Report Definition List;

%macro prt_exception;

	%local text1;
	%local text2;
	%local text3;


 %if %upcase(&dset)=ZH37 %then %do;
		%let text1=%str(_______________________Right(kg)____________________);
		%let text2=%str(_______________________Left(kg)____________________);
		column ( 
/*			%if %upcase(&compare)=Y %then %str( q2type q2comment );*/
			__n visit a_dov  ITMHGSASSESS		
			("!{style [just=c fontweight=bold]&text1}" ITMHGSRIGHTMEAS1_  ITMHGSRIGHTMEAS2_ ITMHGSRIGHTMEAS3_ ITMHGSRIGHTMAX_)
			("!{style [just=c fontweight=bold]&text2}" ITMHGSLEFTMEAS1_ ITMHGSLEFTMEAS2_ ITMHGSLEFTMEAS3_ ITMHGSLEFTMAX_)
		)__:;

		define VISIT / style(column)=[width=0.8in];
		define A_DOV / style(column)=[width=0.8in];
		define ITMHGSASSESS / style(column)=[width=1.1in];
		define ITMHGSRIGHTMEAS1_/ style(column)=[just=c cellwidth=0.9in] style(header)=[just=c];
		define ITMHGSRIGHTMEAS2_/ style(column)=[just=c cellwidth=0.9in] style(header)=[just=c];
		define ITMHGSRIGHTMEAS3_/ style(column)=[just=c cellwidth=0.8in] style(header)=[just=c];
		define ITMHGSLEFTMEAS1_/ style(column)=[just=c cellwidth=0.9in] style(header)=[just=c];
		define ITMHGSLEFTMEAS2_/ style(column)=[just=c cellwidth=0.9in] style(header)=[just=c];
		define ITMHGSLEFTMEAS3_/ style(column)=[just=c cellwidth=0.8in] style(header)=[just=c];
		define ITMHGSRIGHTMAX_/ style(column)=[just=c cellwidth=0.5in] style(header)=[just=c];
		define ITMHGSLEFTMAX_/ style(column)=[just=c cellwidth=0.5in] style(header)=[just=c];
	%end;

	%else %if %upcase(&dset)=AE28 %then %do;
		define ITMAESEQNUM / style(column)=[width=0.6in];
		define ITMAEEVENT / style(column)=[width=1.2in];
		define ITMAESTARTDT_DTS / style(column)=[width=0.8in];
		define ITMAEOUT / style(column)=[width=0.9in];
		define ITMAESEV /style(column)=[width=0.8in];
		define ITMAERELCHEM / style(column)=[width=1.0in];
		define ITMAEACN / style(header)=[just=c] style(column)=[width=0.9in];
		define ITMAEACNOTH /style(column)=[width=1.0in];
		define ITMAESER_ / style(column)=[just=c width=0.5in] style(header)=[just=c];
		define ITMAEEQFIRSTDOSE / style(column)=[width=1.0in just=c];

	%end;

	%else %if %upcase(&dset)=SAE %then %do;
		%let text=%str( Hospitalization );
		column ( 
			__n ITMAESEQNUM DEATHCI ITMAEAUTPRF ITMAESERYES_CITMLIFETHR 
			("!{style [just=c fontweight=bold textdecoration=underline]&text}" ITMAEADMDT_DTS  ITMAEDISCHDT_DTS)
			ITMAESERYES_CITMDISINC ITMAESERYES_CITMCONGANOM ITMAESERYES_CITMIMPMEDEVT ITMAEOTHPOSCAUS ITMAEIMPROVED ITMAEREAPPEAR ITMAELASTDOSEDT_DTS
			)__:;

		define ITMAESEQNUM / style(column)=[cellwidth=0.5in];
		define DEATHCI / style(column)=[just=c cellwidth=0.7in] style(header)=[just=c];
		define ITMAEAUTPRF / style(column)=[just=c cellwidth=0.5in];
		define ITMAESERYES_CITMLIFETHR / style(column)=[just=c cellwidth=0.8in];
		define ITMAEADMDT_DTS / style(column)=[just=c] style(header)=[just=c];
		define ITMAEDISCHDT_DTS / style(column)=[just=c] style(header)=[just=c];
	%end;
/*	%else %if %upcase(&dset)=QS37_1 or %upcase(&dset)=QS37_2 or %upcase(&dset)=QS40  %then %do;*/
/*		define qstest:/style(column)=[cellwidth=2.5in];*/
/*		define _:/style(column)=[cellwidth=0.25in];*/
/*	%end;*/

	%else %if %upcase(&dset)=PEALL %then %do;
		define VISIT / style(column)=[width=2.0in];
		define A_DOV / style(column)=[width=2.0in just=l];
		define PEPERF / style(column)=[width=2.0in];
		define ABNORMAL / style(column)=[width=2.0in just=l];
	%end;

/*		%else %if %upcase(&dset)=VSALL %then %do;*/
/*		define VISIT / style(column)=[width=1.0in];*/
/*		define A_DOV / style(column)=[width=1.0in];*/
/*		define FLAG / style(column)=[width=1.0in];*/
/*		define ITMVSDT_DTS / style(column)=[width=0.8in];*/
/*		define HEIGHT / style(header)=[just=c] style(column)=[just=c cellwidth=0.7in];*/
/*		define WEIGHT / style(header)=[just=c] style(column)=[just=c cellwidth=0.7in];*/
/*		define BMI / style(header)=[just=c] style(column)=[just=c cellwidth=0.6in];*/
/*		define TEMP / style(header)=[just=c] style(column)=[just=c cellwidth=0.9in];*/
/*		define HR / style(column)=[just=c width=0.9in] style(header)=[just=c];*/
/*		define RESP / style(header)=[just=c] style(column)=[just=c cellwidth=1.2in];*/
/*		define BP / style(column)=[just=c width=1.2in] style(header)=[just=c];*/
/*	%end;*/
	%else %if %upcase(&dset)=VSALL %then %do;
		define TEST / ' ';
		define TEST / style(column)=[width=2.0in];
		define V_:/style(column)=[cellwidth=1.2in just=l];
	%end;

		%else %if %upcase(&dset)=CM28 %then %do;
		define ITMCMMED / style(column)=[width=1.5in];
		define ITMCMREASON / style(column)=[width=1.5in];
		define ITMCMSTARTDT_DTS / style(column)=[width=1.0in];
		define ITMCMEND_DTS_ / style(column)=[width=1.0in];
		define ITMCMDOSE / style(column)=[width=0.6in];
		define ITMCMUNITS / style(column)=[width=0.7in];
		define ITMCMROUTE / style(column)=[width=0.8in];
		define ITMCMFREQ / style(column)=[width=1.0in];
	%end;

/**/
/*		%else %if %upcase(&dset)=QS33 %then %do;*/
/*		define VISIT / style(column)=[width=1.5in];*/
/*		define A_DOV / style(column)=[width=1.5in];*/
/*		define ITMKARNOFSKYPERF / style(column)=[width=1.5in];*/
/*		define ITMKARNOFSKYSCORE / style(column)=[width=5.5in];*/
/*	%end;*/

		%else %if %upcase(&dset)=EG20 %then %do;
		define VISIT / style(column)=[width=1.4in];
		define A_DOV / style(column)=[width=1.4in];
		define ITMECGPERF / style(column)=[width=1.6in];
		define ITMECGOVEINT / style(column)=[width=5.0in];
	%end;

		%else %if %upcase(&dset)=ZB27 %then %do;
		define VISIT / style(column)=[width=3in];
		define A_DOV / style(column)=[width=3in];
		define ITMDXAPERF / style(column)=[width=3in];
	%end;


	%else %if %upcase(&dset)=FAALL %then %do;
		%let text=%str(   AJCC stage   );
		column ( 
			__n VISIT A_DOV FLAG HISTOLOGY FASTDTC 
			("!{style [just=c fontweight=bold textdecoration=underline]&text}" NSCLCT  NSCLCN NSCLCM)
			OVSTG SITE 
			)__:;

		define VISIT / style(column)=[width=1.0in];
		define A_DOV / style(column)=[width=1.0in];
		define FLAG / style(column)=[width=1.0in];
		define HISTOLOGY / style(column)=[width=1.0in];
		define FASTDTC / style(column)=[width=1.3in];
		define NSCLCT / style(column)=[cellwidth=0.5in just=c] style(header)=[just=c];
		define NSCLCN / style(column)=[cellwidth=0.5in just=c] style(header)=[just=c];
		define NSCLCM / style(column)=[cellwidth=0.5in just=c] style(header)=[just=c];
		define OVSTG / style(column)=[width=1.2in just=c] style(header)=[just=c];
		define SITE / style(column)=[width=1.7in];
	%end;

/*		%else %if %upcase(&dset)=XCALL %then %do;*/
/*		define VISIT / style(column)=[width=0.8in];*/
/*		define A_DOV / style(column)=[width=1.0in];*/
/*		define REGION / style(column)=[width=1.3in];*/
/*		define ITMPRVCHREG / style(column)=[width=0.8in];*/
/*		define ITMPRVCHCYTCHEM / style(column)=[width=1.4in just=c] style(header)=[just=c width=1.4in];*/
/*		define TOTDOSE / style(column)=[width=0.8in just=c] style(header)=[width=0.8in just=c];*/
/*		define STDTC / style(column)=[width=0.8in];*/
/*		define ENDTC / style(column)=[width=0.8in];*/
/*		define FLAG / style(column)=[width=0.8in];*/
/*	%end;*/
	
	%else %if %upcase(&dset)=VISITIDX %then %do;
		define VISIT / style(column)=[width=4.5in];
		define visit2 / style(column)=[width=4.5in];
	%end;

		%else %if %upcase(&dset)=QSIDX %then %do;
		define qs1_ / style(column)=[width=0.7in];
		define qs2_ / style(column)=[width=4.0in];
        define qs1 / style(column)=[width=0.7in];
		define qs2 / style(column)=[width=4.5in];
	%end;

	%else %if %upcase(&dset)=AEIDX %then %do;
		define ITMAESEQNUM / style(column)=[width=1.3in just=l];
		define _LABEL_ / style(column)=[width=2in];
		define COL1 / style(column)=[width=6.5in];
	%end;

	%else %if %upcase(&dset)=REFRANGE %then %do;
		define item / style(column)=[width=1.8in];
		define low /'Lower Limit' style(column)=[width=3in just=l] ;
		define high /'Upper Limit' style(column)=[width=3in just=l] ;
	%end;


	%else %if %upcase(&dset)=DM06 %then %do;
		define visit / style(column)=[width=0.6in];
		define a_dov / style(column)=[width=0.6in];
		define ITMDMDOB_DTS / style(column)=[width=0.6in];
		define ITMDMIFCDT_DTS / style(column)=[width=1.0in];
		define ITMUPWRKFLW_CITMUPWRKFLW / style(column)=[width=1in];
		define ITMDMPERFSCRDAY1 / style(column)=[width=2in];
		define ITMDMPERFSCRDAY85 / style(column)=[width=3.2in];
	%end;
	%else %if %upcase(&dset)=MH06 %then %do;
		define visit / style(column)=[width=1.1in];
		define a_dov / style(column)=[width=1.0in];
		define ITMMHCOND / style(column)=[width=3.0in];
		define ITMMHSTARTDT_DTS / style(column)=[width=1.2in];
		define MHENDTC / style(column)=[width=1.2in];
	%end;
	%else %if %upcase(&dset)=ECOG17 %then %do;
		define a / '';
		define a_dov / style(column)=[width=1.0in];
		define ITMECOGDT_DTS / style(column)=[width=1.2in];
		define visit / style(column)=[width=1.0in];
	%end;
	%else %if %upcase(&dset)=SC13 %then %do;
		%let text1=%str(Screening BMI < 20 kg/m2);
		%let text2=%str(                        Screening BMI >= 20 kg/m2                        );
		column ( 
			__n   VISIT  A_DOV SCRBMI
			("!{style [just=c fontweight=bold textdecoration=underline]&text1}" BMIWTH)			
			("!{style [just=c fontweight=bold textdecoration=underline]&text2}" ITMBMIWTHXPRWGHTDT_DTS WEIGHT ITMBMIWTHXWEIGHTMTH)
		)__:;
		define visit/ style(column)=[width=0.8in];
		define A_DOV/ style(column)=[width=0.8in];
		define SCRBMI/ style(column)=[just=c width=1.2in] style(header)=[just=c];
		define BMIWTH/ style(column)=[width=1.7in] style(header)=[just=c];
		define ITMBMIWTHXPRWGHTDT_DTS/ style(column)=[just=c width=1.5in] style(header)=[just=c];
		define WEIGHT/ style(column)=[just=c width=1.0in] style(header)=[just=c];
		define ITMBMIWTHXWEIGHTMTH/ style(column)=[just=c width=1.8in] style(header)=[just=c];
	%end;
	%else %if %upcase(&dset)=TUTR %then %do;
		define TUMCOD / style(column)=[just=c width=0.5in];
		define PROCEDURE / style(column)=[width=1in];
		define UPSUM_CITMCHECKED_C / style(column)=[width=1.0in];
		define EVALDT / style(column)=[width=0.6in];
		define DIAM / style(header)=[just=c] style(column)=[just=c];
		define DIAMSUM / style(header)=[just=c] style(column)=[just=c];
	%end;
	%else %if %upcase(&dset)=TUTRN %then %do;
		define TUMCOD / style(column)=[just=c] style(header)=[just=c];
	%end;
	%else %if %upcase(&dset)=RS52 %then %do;
		define NTARCD / style(column)=[width=1.2in];
		define NONTARLES / style(column)=[width=1.5in];
	%end;

/*	%else %if %upcase(&dset)=LBURIN %then %do;*/
/*		define SG / style(column)=[just=c];*/
/*	%end;*/
		%else %if %upcase(&dset)=LBURIN %then %do;
		define TEST / ' ';
		define TEST / style(column)=[width=2.0in];
		define V_910 / ' ';
		define V_920 / ' ';
		define V_930 / ' ';
		define V_:/style(column)=[width=1.5in just=l] ;
	%end;
	%else %if %upcase(&dset)=DS49 %then %do;
		/*Ken on 2013/07/16: Adjust column width*/
		define VISIT / style(column)=[width=1.2in];
		define a_dov/ style(column)=[width=1.2in];
		define COMPLETE / style(column)=[width=1.5in];
		define REASON / style(column)=[width=2.5in];
		/*Ken on 2013/07/15: Remove blow fields as per client's comments*/
		define ITMEOSBLIND / noprint;
		define ITMEOSBLINDBROKEDT_DTS /noprint;
		define ITMEOSBLINDBROKERSN /  noprint;
	%end;
	%else %if %upcase(&dset)=VSFU50 %then %do;
		define WEIGHT / style(column)=[just=c];
		define WEIGHT / style(header)=[just=c];
	%end;
	%else %if %upcase(&dset)=ZS54 %then %do;
		define VISIT / style(column)=[width=0.6in];
		define SURVIVALDT / style(column)=[width=0.7in];
		define ITMSURVIVALMETHCON / style(column)=[width=1.2in];
		define STATUS / style(column)=[width=1.2in];
		define ITMSURVIVALAUTOPERF / style(column)=[width=1.0in];
		define CAUDEATH / style(column)=[width=0.8in];
		define ITMSURVIVALLSTPHDT_DTS / style(column)=[width=1.2in];
		define ITMSURVIVALREGLETDT_DTS / style(column)=[width=1.5in];
	%end;


	%else %if %upcase(&dset)=QS37 %then %do;
		define _:/style(column)=[width=0.5in just=c] style(header)=[just=c];
		define N5 /style(column)=[width=0.5in just=c] style(header)=[just=c];
		define A /style(column)=[width=0.4in]'';
		define QSTEST / style(column)=[width=3.0in];
		define QSTEST_ / style(column)=[width=3.0in];
	%end;

	%else %if %upcase(&dset)=QS40 %then %do;
		define _:/style(column)=[width=0.5in just=c] style(header)=[just=c];
		define N5 /style(column)=[width=0.5in just=c] style(header)=[just=c];
		define B /style(column)=[width=0.4in]'';
		define QSTEST / style(column)=[width=3.0in];
		define QSTEST_ / style(column)=[width=3.0in];
	%end;
	%else %if %upcase(&dset)=QS33 %then %do;
		define QSTEST /style(column)=[width=1.3in] ' ';
		define V_:/style(column)=[width=1.3in] ;
	%end;

	%else %if %upcase(&dset)=QS41 %then %do;
		define QSTEST /style(column)=[width=4.0in]' ';
		define V_:/style(column)=[width=1.6in];
	%end;

	%else %if %upcase(&dset)=LBHEM %then %do;
		define TEST / ' ';
		define TEST / style(column)=[width=2.0in];
		define lbrange_s / id 'Normal Range';
		define lbrange_s / style(column)=[width=1.4in just=c] style(header)=[just=c];
		define V_:/style(column)=[width=1.0in just=l];
	%end;

/*	%else %if %upcase(&dset)=LBCHEM %then %do;*/
/*		define TEST /style(column)=[width=1.5in]' ';*/
/*		define rangelh_s /id 'Normal Range';*/
/*		define rangelh_s /style(column)=[width=1in just=c] style(header)=[width=1in just=c];*/
/*		define V_:/style(column)=[width=1.3in just=l];*/
/*	%end;*/

		%else %if %upcase(&dset)=LBCHEM %then %do;
		define TEST /style(column)=[width=2.0in]' ';
		define rangelh_s /id 'Normal Range';
		define rangelh_s /style(column)=[width=1.4in just=c] style(header)=[just=c];
		define V_:/style(column)=[width=1.0in just=l];
	%end;


	%else %if %upcase(&dset)=LBCHEM25 %then %do;
		define TESTOTH /style(column)=[width=2in]' ';
		define V_:/style(column)=[width=2in just=l] ;
	%end;

	%else %if %upcase(&dset)=YC44 %then %do;
		define ITMPROCREC /style(column)=[width=5in];
		define ITMPROCSTARTDT_DTS /style(column)=[width=5.5in];
	%end;
	%else %if %upcase(&dset)=LBRANGE %then %do;
		define LBCAT / style(column)=[width=1.2in];
		define A_VISITMNEMONIC / style(column)=[width=1.2in];
		define TEST1 / style(column)=[width=1.0in] 'Test';
		define unit / style(column)=[width=1.0in];
		define LAB / style(column)=[width=3in] 'Laboratory Name/CRF';
		define LOW / style(column)=[width=1.2in just=c] style(header)=[just=c];
		define HIGH / style(column)=[width=1.2in just=c] style(header)=[just=c];
	%end;

	
	%else %if %upcase(&dset)=XC42 %then %do;
		define REGION /style(column)=[width=4.0in];
		define TOTDOSE /style(column)=[width=2.0in];
		define STDTC /style(column)=[width=2.0in];
		define ENDTC /style(column)=[width=2.0in];
	%end;

		
	%else %if %upcase(&dset)=XC43 %then %do;
		define STATUS /style(column)=[width=2.5in];
		define ITMCHEMOTHERAPY_ /style(column)=[width=1.8in];
		define ITMCHEMOSTARTDT_DTS /style(column)=[width=1.0in];
		define ITMCHEMOENDDT_DTS_ /style(column)=[width=1.0in];
		define ITMCHEMOSTARTDOSE /style(column)=[width=0.8in];
		define ITMCHEMOENDDOSE /style(column)=[width=0.7in];
		define ITMCHEMOUNITS /style(column)=[width=0.7in];
		define ITMCHEMOROUTE /style(column)=[width=0.8in];
		define ITMCHEMOFREQ /style(column)=[width=1.0in];

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

	***;


%mend prt_exception;
