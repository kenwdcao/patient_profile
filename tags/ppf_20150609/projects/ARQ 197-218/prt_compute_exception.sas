* Program Name: prt_compute_exception.sas;
* Initial Date: 19/02/2014;
* Add user defined compute block within each data module in patient profile;

%macro prt_compute_exception();
    
    %if %upcase(&dset) = AE %then
        %do;
            /*highlight if SAE*/
            compute aeser;
                if aeser = 'Y' then call define (_row_, 'style', 'style = [background = #FFFFCC]');
            endcomp;
			/*highlight if AE related to study drug*/
			compute aerel_c;
				if substr(aerel_c, 1, 2) = 'Y:' then 
					do;
						call define (_row_, 'style', 'style = [background = #DBE5F1]');
						/*if both SAE and drug related*/
						if aeser = 'Y' then 
							do;
								call define (_row_, 'style', 'style = [background = #FFFFCC]');
								call define ('aerel_c', 'style', 'style = [background = #DBE5F1]');
							end;
					end;
			endcomp;
        %end;
    %else %if %upcase(&dset) = TARGET %then
        %do;
            /*If SUM, then highlight the row with yellow*/
            compute __sumline;
                if __sumline = 'Y'  then call define (_row_, 'style', 'style = [background = #FFFFCC fontweight=bold]');
            endcomp;
			compute teval;
				if index(teval, 'Not Evaluated:') = 1 then
					call define (_row_, 'style', 'style = [textdecoration=line_through]');
			endcomp;
        %end;
    %else %if %upcase(&dset) = NTARGET %then
        %do;
            /*highlight if Lesion is new */
            compute status;
				if status = 'Unequivocal Progression' then
					call define (_row_, 'style', 'style = [background = #FFFFCC]');
				if status = 'New' then
					call define (_row_, 'style', 'style = [background = #FFFFCC]');
            endcomp;
			compute nteval;
				if index(nteval, 'Not Evaluated:') = 1 then
					call define (_row_, 'style', 'style = [textdecoration=line_through]');
			endcomp;
        %end;
	%else %if %upcase(&dset) = SAE %then
		%do;
			/*highlight drug related ae*/
            compute aerel;
                if aerel = 'Yes' then call define (_row_, 'style', 'style = [background = #DBE5F1]');
            endcomp;
		%end;
	

%mend prt_compute_exception;
