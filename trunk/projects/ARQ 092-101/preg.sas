
%include '_setup.sas';

data preg0;
    length lbtest $100 lborres $200 lbdtc $60 visit $100 visitnum 8;
    set source.preg;
    where pregynna ^= 2;
    lbtest='Pregnancy Test';
    visit=strip(put(event_id,$visit.));
    visitnum=input(put(event_id,$vnum.),best.);
    if pregdtc^='' then lbdtc=strip(pregdtc);
    if pregynna=0 then lborres='Not Done, '||strip(prgnosp);
            else if pregynna=1 then do;
                if pregres=1 then lborres='Negative';
                    else if pregres=2 then lborres='Positive';
            end;


    label 
        visit   = 'Visit'
        lbdtc   = 'Date of Pregnancy Test'
        lborres = 'Pregnancy Test Results'
    ;
run;

proc sort data = preg0; by subid visitnum; run;

data pdata.preg(LABEL='Pregnancy Test');
    retain subid visit lbdtc lborres ;
    keep subid visit lbdtc lborres;
    set preg0;
run;
