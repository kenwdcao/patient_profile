
/*
    
    Program Name: chkSubj.sas
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Initial Date: 2013/04/17

    ****************************************************************************
    This program checks the validity of subjects specified in parameter subsets.
    Only valid subjects would be kept in parameter subsets.
    ****************************************************************************
    
*/


%*local validsubjects;
%macro chkSubj(subjects=,dlm=);
    %local blank;
    %let blank=;

    %local subjcnt;
    %local subjects2;
    %local i;
    %local subj;
    %local indemog;



    %if %length(&subjects)=0 %then %let subjcnt=0;
    %else %let subjcnt=%eval(%sysfunc(countc(&subjects,"&dlm"))+1);

    %let subjects2=&subjects;
    %let subjects=;

    ** remove where statement in DEMODSET (SUBSETS > DEMODSET);
    %let demodset = %scan(&demodset, 1, ());

    %do i=1 %to &subjcnt;
        %let subj=%scan(&subjects2,&i,%str(&dlm));
        %let subj=%sysfunc(strip(&subj));
        %let indemog=0;

        data _null_;
            set &PDATALIBRF..&demodset;
            if &subjectvar="&subj" then do;
                call symput('indemog','1');
                stop;
            end;
        run;

        %if &indemog=0 %then %do;
            %put ERR%str(&blank)OR: Subject &subj not in demographic dataset &PDATALIBRF..&demodset;
        %end;
        %else %do;
            %if %length(&subjects)>0 %then %let subjects=&subjects&dlm&subj;
            %else %let subjects=&subj;
        %end;
    %end;
    
    %let validsubjects=&subjects;
%mend chkSubj;
