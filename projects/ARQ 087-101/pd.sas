/*
    Program Name: PD.sas
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Initial Date: 2014/01/06
*/

%include '_setup.sas';

data pd0;
    set source.pd;
    keep subid pddtc pdreas pdreassp pdwaive pddet;
run;

data pd1;
    set pd0;
    length pdreason $256 pawaivec $10;
    label pdreason = 'Deviation/Violation Reason'
          pdwaviec = 'Waiver?'
    ;
    pdreason  = put(pdreas, PDREAS.);
    if pdreas = 99 then pdreason = strip(pdreason)||': '||strip(pdreassp);
    pdwaivec  = put(pdwaive, NOYES.);
    drop pdreas pdreassp pdwaive;
run;

proc sort data = pd1; by subid pddtc; run;

data pdata.pd (label = 'Protocol Violation and Deviation');
    retain subid pddtc pdreason pdwaivec pddet;
    keep   subid pddtc pdreason pdwaivec pddet;
    set pd1;
run;
