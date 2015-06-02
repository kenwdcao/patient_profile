%include '_setup.sas';

data me0;
    set source.me;
    label ejecfrac = 'Ejection Fraction(%)';

    length visit $200;
    visit=strip(put(event_id,$visit.));
    visitnum=input(put(event_id,$vnum.),best.);

    label 
        visit = 'Visit'
        mugadtc = 'Date of MUGA/Echocardiogram'
    ;

run;

proc sort data = me0; by subid event_no; run;


data pdata.me(label='MUGA/Echocardiogram');
    retain subid visit mugayn mugaynsp mugadtc ejecfrac;
    keep subid visit mugayn mugaynsp mugadtc ejecfrac;
    set me0;
run;
