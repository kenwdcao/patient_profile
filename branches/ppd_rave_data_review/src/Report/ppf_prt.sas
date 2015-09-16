/*

    Program Name: ppf_prt.sas
        @Author: Ken Cao (yong.cao@q2bi.com).
        @Intial Date: 2013/05/21
    
    *******************************************************************
    This program inherits most functions from old ppf_prt programs. New
    program is designed under modulization concept.
    Key procedures of this macro listed as below,
    1. Determine subjects to be printed.
    2. Determine datasets to be printed.
    3. Loop by subjects.
        (1) Print TOC (optional)
        (2) Loop by datasets
            1) get paramters for the dataset
            2) subset
            3) print dataset label
            4) print dataset (proc report, configurable).
        
    ******************************************************************* 

*/




/*
    Ken Cao on 2013/06/02: Fix a bug of pdf linkage.
    Ken Cao on 2014/06/16: If NOPRINTWHENNODATA is set to Y and NOBS=0 then dataset will not be printed.
    Ken Cao on 2014/11/27: Add RTF output. RTF output needs independent code (for consideration of optimization).
    Ken Cao on 2014/12/02: Redesign this macro to generate RTF and PDF report independently.
    
*/


%macro ppf_prt(demodset=,subsets=, dlm4subj=, subjectvar=,dsetconfig=,headfootconfig=, pdfstyle=, rtfstyle=);
    
    %local blank;
    %let blank=;

    %local allval;
    %local count;
    %local allsubj;
    %local subjcnt;
    %local subj;
    %local alldset;
    %local dsetcnt;
    %local i;
    %local subj;

    %let subsets = %sysfunc(prxchange(s/^&dlm4subj+// , -1, %str(&subsets)));
    %let subsets = %sysfunc(prxchange(s/&dlm4subj+$// , -1, %str(&subsets)));
    %let subsets = %sysfunc(prxchange(s/&dlm4subj+/&dlm4subj/ , -1, %str(&subsets)));

    %*put &subsets;
    ************************************************************************************;
    *determine all subjects to be printed, load all subjects in macro variable allsubj;*
    ************************************************************************************;
    **delimieter used for separating different subjects;
    %if %length(&dlm4subj)=0 %then %let dlm4subj=%str(@);
    **Priority: SUBJECTS>DEMODSETS;
    %if %length(&subsets)>0 %then 
    %do;
        %local validsubjects;
        %chksubj(subjects=&subsets,dlm=&dlm4subj);
        %let allsubj=&validsubjects;
        %if %length(&allsubj)=0 %then %let subjcnt=0;
        %else %let subjcnt=%eval(%sysfunc(countc(&allsubj,"&dlm4subj"))+1);
    %end;
    %else %if %length(&demodset)>0 %then 
    %do;
        %getallval(indata=&PDATALIBRF..&demodset,invar=&subjectvar,dlm=%nrbquote(&dlm4subj));
        %let allsubj=&allval;;
        %let subjcnt=&count;;

        %put &allsubj;
        %put &subjcnt;
    %end;
    **If no subjects specified, then put an  E R R O R;
    %if &subjcnt<=0 %then
    %do;
        %put ERR%str(&blank)OR: Zero subject will be printed, execution aborted;
        %let ReturnCode=1;
        %return;
    %end;

    ************************************************************************************;
    *determine all datasets to be printed, load all datasets in macro variable alldset;
    ************************************************************************************;
    proc sort data=&dsetconfig; by ord; run;
    %getallval(indata=&DSETCFG,invar=dset);
    %let alldset=&allval;
    %let dsetcnt=&count;
    **If no subjects specified, then put an  E R R O R;
    %if &dsetcnt=0 %then 
    %do;
        %put ERR%str(&blank)OR: Zero dataset will be printed, execution aborted.;
        %let ReturnCode=1;
        %return;
    %end;


    ************************************************************************************;
    *Loop with subjects to generate datasets*;
    ************************************************************************************;
    %do i = 1 %to &subjcnt;
        %let subj    = %scan(&allsubj,&i,"&dlm4subj");
        

        ** print RTF output **;
        %if &genRTF = Y %then %do;
            %printSubject(&subj, &alldset, RTF, &rtfStyle);
        %end;

        ** print RTF output **;
        %if &genPDF = Y %then %do;
            %if &pdfFormat = PS %then %do;
                %printSubject(&subj, &alldset, PS, &pdfStyle);
            %end;
            %else %if &pdfFormat = PDF %then %do;
                %printSubject(&subj, &alldset, PDF, &pdfStyle);
            %end;
        %end;

    %end;

    
%mend ppf_prt;
