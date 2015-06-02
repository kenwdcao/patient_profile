
%macro data_exception;
    %if &nobs = 0 %then
        %do;
            %makeBlankRecord(&dset);
				/* Ken on 2014/03/10: 0.5 can be used as an flag in prt_compute_exception. */
            %let nobs = 0.5;
        %end;
%mend data_exception;
