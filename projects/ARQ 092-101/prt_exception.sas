
* -----> Special Report Definition List;

%macro prt_exception;

    %local text1;
    %local text2;
    %local text3;

    %if %upcase(&dset)=MH %then %do;
        define MHTERM/ style(column)=[width=3.3in];
        define MHONDTC/ style(column)=[width=2in];
        define MHENDDTC/ style(column)=[width=2in];
        define MHENRF/ style(column)=[just=c width=2.5in] style(header)=[just=c];
    %end;

    %else %if %upcase(&dset)=SFU %then %do;
        define TERM/ '' ;
        define RESPONSE/ '';
    %end;

    %else %if %upcase(&dset)=MH01 %then %do;
        
    /* Ken Cao on 2014/11/26: remove second header as per client comments
        column ( 
            __n MHSCAT PRIM CHHISTOL CHMSUB CHLOCATE BPTYPE  
            ("&escapechar{style [just=c]Initial Histologic Diagnosis}" CHDGDTC GRADE)
            __blank__ 
            ("&escapechar{style [just=c]Tumor Staging}" STGD STGE)
            )__:;
     */
        define MHSCAT/ 'Diagnosis Information/#Cancer Types' style(column)=[width=1.2in];
        define PRIM/ style(column)=[width=0.7in];
        define CHHISTOL/ style(column)=[ width=1.35in];
        define CHMSUB/ 'Molecular/#Histologic Subtype' style(column)=[width=1.35in];
        define CHLOCATE/ style(column)=[width=1.35in];
        define BPTYPE/ style(column)=[width=0.8in];
        define CHDGDTC/ 'Initial Diag. Date' style(column)=[just=c width=0.8in] style(header)=[just=c];
        define GRADE/ style(column)=[just=c width=1in] style(header)=[just=c ];;
        define STGD/ 'Initial Diag. Stage' style(column)=[just=c width=0.75in] style(header)=[just=c];
        define STGE/ 'Stage at Study Entry' style(column)=[just=c width=0.65in] style(header)=[just=c];

        /*
        define __blank__ / ' ' style(column)=[width=0.05in] computed;

        compute __blank__ / character;
            __blank__ = ' ';
        endcomp;
        */
    %end;

    %else %if %upcase(&dset)=DIS %then %do;
        define REASON/ style(column)=[width=2in];
        define AREASON1/ style(column)=[width=2in];
        define AREASON2/ style(column)=[width=1.8in];
        define SCLVDTC/ 'Date of Subject’s Last #Completed Study Visit' style(column)=[width=1.8in];
        define SCLDDTC/ style(column)=[width=2.2in];
    %end;

    %else %if %upcase(&dset)=CM02 %then %do;
        define INDC/ style(column)=[width=0.9in];
        define TYPE/ style(column)=[width=0.8in];
        define PLRX/ style(column)=[width=1.2in];
        define SGTYPE/ style(column)=[width=1.9in];
        define SGTH/ style(column)=[width=1.6in];
        define PLLOC/ style(column)=[width=1in];
        define DOSE/ style(column)=[width=0.9in];
        define PLSTDTC/ style(column)=[width=0.8in];
        define PLENDDTC/ style(column)=[width=0.8in];
    %end;

    %else %if %upcase(&dset)=CM01 %then %do;
        define PSREG/ style(column)=[just=c] style(header)=[just=c];
        define PSSCHED/ style(column)=[width=1in];
        define PSPGDTC/ style(column)=[width=0.8in];
        define INTD/ style(column)=[width=1in];
        define PSBRDTC/ style(column)=[width=1.2in];
        define PSNUM_ / style(column)=[just=c];
    %end;

    %else %if %upcase(&dset)=EX %then %do;
        /* Ken Cao on 2014/09/02: Group variable ABATE and REAP together */
        /* Ken Cao on 2014/11/12: remove second header as per client comments
        column __n SDSTDTC SDENDDTC EXDOSE REASON1 
            ("&escapechar{style [just=c]Dose Held due to AE}" ABATE REAP)
            REASON2 REDOSE REDTC __:;
        */
        define EXDOSE/ style(column)=[just=c width=0.9in] style(header)=[just=c];
        define SDSTDTC/ style(column)=[width=0.85in];
        define SDENDDTC/ style(column)=[width=0.8in];
        define REASON1/ 'Was Dosing Stop #A Planned Hold?' style(column)=[width=1.4in];
        define REASON2/ 'Was Dosing Reduction Required?' style(column)=[width=1.3in];
        define ABATE/ 'AE Abate after Held?' style(column)=[width=1.1in];
        define REAP/ 'AE Reappear after Resumed?' style(column)=[width=1.1in];
        define REDOSE/ style(column)=[width=0.9in];
        define REDTC/ 'Date Dosing #Resumed/Reduced' style(column)=[width=1.3in];
    %end;

    %else %if %upcase(&dset)=EXDIS %then %do;
        define DSDDCDTC/ style(column)=[just=l] /*style(header)=[just=c]*/;
        define RNDC/ style(column)=[width=2.5in];
        define SDAESTDC/ style(column)=[width=1.5in];
        define SDDCRNSP / 'If Other or Physician Decision, Specify' style(column)=[width=2.5in];;
        define SDAESP / 'If AE/SAE, Specify' style(column)=[width=2.5in];;
    %end;
    
    %else %if %upcase(&dset) = TUT %then %do;
        define visit / style(column) = [width=1.5in];
        define analoc / style(column) = [width=3.5in];
    %end;

     %else %if %upcase(&dset) = TUNT %then %do;
        define visit / style(column) = [width=1.5in];
    %end;

    %else %if %upcase(&dset) = TUNT %then %do;
        define visit / style(column) = [width=1.5in];
    %end;

    %else %if %upcase(&dset) = HEMA %then %do;
        define lborres / style(column) = [just=c width=2in] style(header)=[just=c ];
        define lbrange / style(column) = [just=r] style(header)=[just=r];
    %end;

    %else %if %upcase(&dset) = LBCOAG %then %do;
        define lborres / style(column) = [just=c width=2in] style(header)=[just=c ];
        define lbrange / style(column) = [just=r] style(header)=[just=r];
    %end;

    %else %if %upcase(&dset) = CHEM %then %do;
        define lborres / style(column) = [just=c width=2in] style(header)=[just=c ];
        define lbrange / style(column) = [just=r] style(header)=[just=r];
    %end;

    %else %if %upcase(&dset) = LBURIN %then %do;
        define lborres / style(column) = [just=c width=2in] style(header)=[just=c ];
        define lbrange / style(column) = [just=r] style(header)=[just=r];
    %end;

    %else %if %upcase(&dset)=CM %then %do;
       define cmindc / 'Primary Indication for Use';
    %end;

    %else %if %upcase(&dset)=EXTRA01 %then %do;
        define VISIT/ style(column)=[width=0.8in];
        define TUDTC/ style(column)=[width=0.9in];
        define BMINVOL/ style(column)=[width=1.2in];
        define CELLTYP/ style(column)=[width=0.6in];
        define BMSTAT/ style(column)=[width=1.0in];
        define LVINVOL/ style(column)=[width=0.7in];
        define LVSIZE/ style(column)=[width=2.2in];
        define SPINVOL/ style(column)=[width=0.7in];
        define SPSIZE/ style(column)=[width=2.2in];
    %end;

    %else %if %upcase(&dset)=EXTRA02 %then %do;
        define MNODULE/ style(column)=[just=c] style(header)=[just=c] ;
    %end;   
    %else %if %upcase(&dset)=EXTRA03 %then %do;
        define MNODULE/ style(column)=[just=c] style(header)=[just=c] ;
    %end;   

    %else %if %upcase(&dset)=RSLYM %then %do;
        define RSYN/ style(column)=[width=0.7in];
        define VISIT/ style(column)=[width=0.9in];
        define RSDTC/ style(column)=[width=0.8in];
        define NODMAS/ style(column)=[width=1.5in];
        define LSPEEN/ style(column)=[width=1.5in];
        define BMAROW/ style(column)=[width=1.5in];
        define MDISEA/ style(column)=[width=0.7in];
        define NEWDISEA/ style(column)=[width=0.6in];
        define OVERASS/ style(column)=[width=1.5in];
        define COMMENT/ style(column)=[width=0.6in];
    %end;


    %else %if %upcase(&dset)=AE %then %do;
        define AEDESC/ style(column)=[width=1.0in];
        define M_PT/ style(column)=[width=1.0in];
        define AENCI/ style(column)=[just=c];;
    %end;

    %else %if %upcase(&dset) = PD %then %do;
        define pddtc / 'Deviation/Violation Date' style(column) = [width=1.0in];
        define pdreas / style(column) = [width=1.5in];
        define pdreassp / style(column) = [width=1.5in];
        define pddet / style(column) = [width=1.5in];
        define pdact / style(column) = [width=1.0in];
        define pdactsp / style(column) = [width=1.5in];
    %end;

    %else %if %upcase(&dset) = EG %then %do;
        define eg: / style(header) = [just=c];
    %end;

%mend prt_exception;

