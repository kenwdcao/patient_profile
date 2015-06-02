/*
    Program: EL.sas
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Initial Date: 2014/11/24
*/

%include '_setup.sas';

data el0;
    set source.el;
    keep subid elyn elexyn exempdtc elexnm exempinc exempexc;
    where elyn = 0;
    ** Ken Cao on 2014/12/01: Original label was truncated due to limitation of SAS Transport File **;
    label 
		ELEXNM = 'ArQule Medical Monitor Granting Exemption'
		EXEMPDTC = 'Date Exemption Granted'
		;
run;


data out.el (label = 'Eligibility ');
    retain subid elexyn exempdtc elexnm exempinc exempexc;
    keep subid  elexyn exempdtc elexnm exempinc exempexc;
    set el0;
run;
