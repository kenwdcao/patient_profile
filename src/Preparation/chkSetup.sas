/*
    Program Name: chkSetup.sas
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Initial Date: 2013/05/29

    ******************************************************
    Check setup.
    ******************************************************
*/

%macro chkSetup();
    %local blank;
    %let blank=;

    %local text;

    /*Check Parameter skipRawDataProcessing*/
    %if %sysfunc(fileexist(&pdatadir\*.sas7bdat))=0 and %upcase(&skipRawDataProcessing)=Y %then
    %do;
        %let text=%str(No datasets detected under &pdatadir.. Parameter skipRawDataProcessing will be changed to N);
        dm "postMessage ""&text""";
        %let skipRawDataProcessing=N;
    %end;

   
%mend chkSetup;
