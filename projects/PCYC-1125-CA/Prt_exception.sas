/********************************************************************************
 Program Nmae: prt_exception.sas
  @Author: 
  @Initial Date: 2015/02/28
 
 Interface to let user customize column statement and define statement in PROC
 REPORT.
 _______________________________________________________________________________

 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/

%macro prt_exception();

%if %upcase(&dset) = BP %then %do;
    column bmdtc lbcode cellular lymph lymcyinv 
        ("&escapechar.S={just=c} Method of Assessment" bmmhe bmmihc bmmmfc bmmmcyto bmmeosp)
        _blankcol_
        ("&escapechar.S={just=c} Additional Samples Collected and Sent to Central Lab"  bmtasp bmtbp bmtnd)
        __:
    ;

     define bmm: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];

     define bmmhe / style(column)=[width=6%] format=checked.;
     define bmmihc / style(column)=[width=5%] format=checked.;
     define bmmmfc / style(column)=[width=7%] format=checked.;
     define bmmmcyto / style(column)=[width=9%] format=checked.;
     define bmmeosp / style(column)=[width=7%];

    define _blankcol_ / ' ' style(column) = [width=1%];
    define bmt: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] style(column)=[width=7%] format=checked.;
%end;

%else %if %upcase(&dset)=DM %then %do;
     column birthdtc cbpyn
        ("&escapechar.S={just=c} If No, Specify Reason" cbpn01c cbpn02c cbpn03c cbpn04c cbpnoc cbpnos)
        ethnic race 
        __:
    ;

    define cbpn: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];   
%end;

%else %if %upcase(&dset)=RS2 %then %do;
     column rsdtc
        ("&escapechar.S={just=c} If Response is ""PD"", Mode of Progression" rstlnum rscntsp rscens rsnewlys rsnewens rscpsp)
        __:
    ;

    define rstlnum / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define rscntsp / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define rscens / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define rsnewlys / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define rsnewens / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define rscpsp / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;

%else %if %upcase(&dset) = ECOG %then %do;
    /*
    column event_id qsdtc qsnd qsorres
        __:
    ;
    */

    define event_id: / style(column) = [width=11%];
    define qsdtc / style(column)=[width=13%];
    define qsnd /  style(column) = [width=11%];
    define qsorres: / style(column) = [width=64%];

%end;

%else %if %upcase(&dset) = ML1 %then %do;
    column mldiag mldtc mlfind mlfindsp 
        ("&escapechar.S={just=c}STAGING"  mlstagnr mlstaget mlstagen mlstagem mlstag)
    __:;
    define mlstag: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define mlstagnr / format=checked.;

%end;

%else %if %upcase(&dset) = ML2 %then %do;
    column mldiag  
        ("&escapechar.S={just=c}TREATMENT"  mltxnone mlsurgsp mlchemsp mlhormsp mlradisp mlothsp)
        mlout mlintent mlantitxs
    __:;
    define mltxnone / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] format=checked.;
    define mlsurgsp / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define mlchemsp / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define mlhormsp / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define mlradisp / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define mlothsp / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;

%else %if %upcase(&dset) = ML3 %then %do;
    column mldiag     
        ("&escapechar.S={just=c}SUBJECT'S CANCER RISK"  mlrsnone mcancrs mlovrwts mlradias mlalcohs mlsmokes mlothrs)
        mlaenum mlmhnum
    __:;
    define mlrsnone / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] format=checked.;
    define mcancrs / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define mlovrwts / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define mlradias / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define mlalcohs / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define mlsmokes / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define mlothrs / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;

%else %if %upcase(&dset) = MH %then %do;
    define mhstdatu / format=checked.;
    define mhongo / format=checked.;
%end;

%else %if %upcase(&dset) = FL1 %then %do;
    define tobongo / format=checked.;
%end;

%else %if %upcase(&dset) = FL2 %then %do;
    define alcongo / format=checked.;
%end;

%else %if %upcase(&dset) = CM %then %do;
    define cmprior / format=checked.;
    define cmongo / format=checked.;
%end;

%else %if %upcase(&dset) = CMRX %then %do;
    define rxongo / format=checked.;
%end;

%else %if %upcase(&dset) = DADM %then %do;
    define daongo / format=checked.;
    define dadisco / format=checked.;
%end;

%else %if %upcase(&dset) = EXRIT1 %then %do;
    define exmd / format=checked.;
    define exdisc / format=checked.;
%end;

%else %if %upcase(&dset) = ML2 %then %do;
    define mlintent / format=checked.;
%end;

%else %if %upcase(&dset) = LBURIN %then %do;
    define lbnd / format=checked.;
%end;

%else %if %upcase(&dset) = LBHEM1 %then %do;
    define lbnd / format=checked.;
%end;

%else %if %upcase(&dset) = LBCHEM1 %then %do;
    define lbnd / format=checked.;
%end;

%else %if %upcase(&dset) = LBPREG %then %do;
    define lbnd / format=checked.;
%end;

%else %if %upcase(&dset) = LBHEPA %then %do;
    define lbnd / format=checked.;
%end;
%else %if %upcase(&dset) = LBCOAG %then %do;
    define lbnd / format=checked.;
%end;

%else %if %upcase(&dset) = LBBIOM1 %then %do;
    define lbnd / format=checked.;
%end;

%else %if %upcase(&dset) = LBBIOM2 %then %do;
    define lbnd / format=checked.;
%end;

%else %if %upcase(&dset) = LBBIOM3 %then %do;
    define lbnd / format=checked.;
%end;

%mend prt_exception;
