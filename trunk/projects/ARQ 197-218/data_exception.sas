* Program Name: data_exception.sas;
* Initial Date: 21/02/2014;



%macro data_exception();

    %if &nobs^=0 and &dset=LBLF %then %do;
            %sendUnit2Header;
        %end;

%mend data_exception;
