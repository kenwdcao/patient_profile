*****************************************************************************;
* Purpose: Patient Profile for Helssin 202                                   *;
* Module: Preparation                                                        *;
* Type: Sas Macro                                                            *;
* Program Name: Start.sas                                                    *;
* Function: Initialization                                                   *;
* Author: Ken Cao (yong.cao@q2bi.com)                                        *;
******************************************************************************;

*->worklibref : SAS library name of active data directory ;
*->bklibref   : SAS library name of backup data directory ;


%macro start(worklibref=,bklibref=);

    %if %upcase(&compare)=Y %then %do;
        %if %upcase(&rerun)=N %then %do;
            *--> Clear datasets in backup directory;
            proc datasets lib=&bklibref kill nolist;
            quit;
            *->Moves datasets in work directory to backup directory;
            proc datasets nolist;
                copy in=&worklibref out=&bklibref move ;
            quit;
        %end;
        %else %do;
            *--> Clear datasets in work directory;
            proc datasets lib=&worklibref kill nolist;
            quit;
        %end;
    %end;
    %else %if %upcase(&compare)=N %then %do;
        *--> Clear datasets in work directory;
        proc datasets lib=&worklibref kill nolist;
        quit;
    %end;

%mend start;
