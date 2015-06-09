/*
    Program Name: OPTH.sas
    @Author: Xiu Pan
    @Initial Date: 2015/01/30


 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.

*/

%include '_setup.sas';

data opth;
    set source.opth(rename=(visit=visit_ EDC_EntryDate=__EDC_EntryDate));
    length opthdtc $10;
    %ndt2cdt(ndt=opthdt, cdt=opthdtc);
    %subject;
    /*if unsseq^=. then visitnum=input(put(strip(visit_)||''||strip(put(unsseq,best.)),$vnum.),best.);
       else visitnum=input(put(visit_,$vnum.),best.);*/
    if unsseq^=. then visit=strip(visit_)||''||strip(put(unsseq,best.));
        else visit=strip(visit_);
        __edc_treenodeid=edc_treenodeid;
    drop edc_:;
run;

data pdata.opth(label=' ');
    retain __edc_treenodeid __EDC_EntryDate subject visit optest oporres opcom opthdtc;
    keep __edc_treenodeid __EDC_EntryDate subject visit optest oporres opcom opthdtc;
    set opth;
    label
    visit='Visit'
    opthdtc='Assessment Date Ophthalmo Exam'
    ;
run;
