
%macro prtblnktab(n);
    %if %length(&n)=0 %then %let n=1;

    %local i;

    data __blnkprt;
        %do i=1 %to &n;
            a=' ';
            output;
        %end;       
    run;

    proc report data=__blnkprt nowd
        style(report)=[
                    bordertopwidth=0 
                    borderbottomwidth=0 
                    borderrightwidth=0 
                    borderleftwidth=0
                    bordertopcolor=white 
                    borderbottomcolor=white 
                    borderleftcolor=white 
                    borderrightcolor=white];

        define a/' ' style(column)=[
                        fontsize=1pt
                        bordertopwidth=0
                        borderbottomwidth=0 
                        borderrightwidth=0 
                        borderleftwidth=0
                        bordertopcolor=white 
                        borderbottomcolor=white 
                        borderleftcolor=white 
                        borderrightcolor=white];
    run;
%mend prtblnktab;
