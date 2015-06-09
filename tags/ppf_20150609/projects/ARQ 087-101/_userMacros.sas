%macro concat(invars =, outvar =, nblank = 2);
    
    %local nvar;
    %local i;
    %local j;
    %local dlm;
    %local nblank2;

    %let nblank2 = %eval(&nblank - 1);

    %let invars = %sysfunc(prxchange(s/\s+/ /, -1, &invars));
    %let invars = %sysfunc(prxchange(s/^\s//, -1, &invars));
    %let invars = %upcase(&invars);
    %let nvar   = %sysfunc(countc(&invars, " "));

    %if %length(&invars) = 0 %then %let nvar = 0;
    %else %let nvar = %eval(&nvar + 1);

    %do i =  1 %to &nvar;
        %local invar&i;
        %let invar&i = %scan(&invars, &i, " ");
    %end;
    
    &outvar = %do i = 1 %to &nvar; "&escapechar{style [fontweight = bold]"|| strip(vlabel(&&invar&i))||'}: '||ifc(&&invar&i > ' ', strip(&&invar&i), 'N/A') %do j = 1 %to &nblank; %str(|| " ")  %end; || %end; " ";
%mend concat;

%macro compose(invars =, lengths =, outvar =);

    %local blank;
    %local nvar;
    %local nlength;
    %local i;


    %let blank   = %str();

    %let invars  = %sysfunc(prxchange(s/\s+/ /, -1, &invars ));
    %let invars  = %sysfunc(prxchange(s/^\s+//, -1, &invars ));
    %let lengths = %sysfunc(prxchange(s/\s+/ /, -1, &lengths));
    %let lengths = %sysfunc(prxchange(s/^\s+//, -1, &lengths));

    %if %length(&invars ) = 0 %then %return;
    %if %length(&lengths) = 0 %then %return;

    %let nvar    = %sysfunc(countc(&invars, " "));
    %let nvar    = %eval(&nvar + 1);
    %let nlength = %sysfunc(countc(&lengths, " "));
    %let nlength = %eval(&nlength + 1);

    %put &nlength;

    %do i = 1 %to &nvar;
        %local invar&i;
        %local length&i;

        %let invar&i = %scan(&invars, &i, " ");
        %if &i > &nlength %then
            %do;
                %let j        = %eval(&i - 1);
                %let length&i = &&length&j;
            %end;
        %else
            %let length&i     = %scan(&lengths, &i, " ");

        length __v&i $256;
        drop __v&i;
        __v&i = vlabel(&&invar&i)||': '||ifc(&&invar&i > ' ', strip(&&invar&i), 'N/A') ;
    %end;

    &outvar = '' %do i = 1 %to &nvar; || substr(__v&i, 1, &&length&i) %end;
    
    

%mend compose;



