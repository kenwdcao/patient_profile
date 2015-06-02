/*
    Program: EL.sas
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Initial Date: 2014/11/24
*/

%include '_setup.sas';

data ie0;
    set source.ie;
    keep subid Bincl Bexcl;
    length Bincl $255 Bexcl $255;
    label Bincl = 'Inclusion Criteria';
    label Bexcl = 'Exclusion Criteria';
    array inc {*} inc:;
    array exc {*} exc:;
    call missing(Bincl, Bexcl);
    do i = 1 to max(dim(inc), dim(exc));
        if i > dim(inc) then goto EXC; 
        /* collect all inclusion criteria not met */
        if inc[i] = 0 then Bincl = strip(Bincl)||ifc(Bincl = ' ', '', ', ')||
        "Inclusion "||substr(vname(inc[i]), 4);
        if i > dim(exc) then continue;
        EXC:
        /* collect all exclusion criteria met */
        if exc[i] = 1 then Bexcl = strip(Bexcl)||ifc(Bexcl = ' ', '', ', ')||
        "Exclusion "||substr(vname(exc[i]), 4);
    end;
    if Bincl > ' ' or Bexcl > ' ';
run;


data pdata.ie(label = 'Inclusion/Exclusion Criteria Violation');
    retain subid Bincl Bexcl;
    keep subid Bincl Bexcl;
    set ie0;
run;


