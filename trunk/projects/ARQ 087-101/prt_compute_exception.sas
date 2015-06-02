%macro prt_compute_exception();
    
    %if %upcase(&dset) = AE %then
        %do;
            compute aesae;
                if aesae = 'Yes' then call define (_row_, 'style', 'style = [background = yellow]');
            endcomp;
            compute aedlt;
                if aedlt = 'Yes' then call define (_row_, 'style', 'style = [background = yellow]');
            endcomp;
        %end;
    %else %if %upcase(&dset) = VISIT %then 
        %do;
            compute __flag;
                if __flag = 'Y' then call define (_row_, 'style', 'style = [background = yellow]');
            endcomp;
        %end;
%mend prt_compute_exception;
