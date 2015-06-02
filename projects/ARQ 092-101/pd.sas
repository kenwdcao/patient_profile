/*
    Author: Ken Cao
    Initial Date: 2014/11/06
    Add Protocol Deviation to patient profile as requested by WXG.
*/

%include '_setup.sas';

data pd0;
    set source.pd;
    where pdyn = 1;
    keep subid pddtc pdreas pdreassp pddet pdact pdactsp pddisc pdwaive;
run;

proc sort data = pd0; by subid pddtc pdreas; run;

data pdata.pd(LABEL='Protocol Deviation');
    retain subid pddtc pdreas pdreassp pddet pdact pdactsp pddisc pdwaive;
    keep subid pddtc pdreas pdreassp pddet pdact pdactsp pddisc pdwaive;
    set pd0;
run;
