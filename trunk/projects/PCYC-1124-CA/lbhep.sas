/********************************************************************************
 Program Nmae: LBHEP.sas
  @Author: Yan Zhang
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';
proc format;
	value $lbtestcd
	'Hepatitis B Core Antibody' = 'HEPB3'
	'Hepatitis B Surface Antibody' = 'HEPB2'
	'Hepatitis B Surface Antigen' = 'HEPB1'
	'Hepatitis C Antibody' = 'HEPC';
run;

data lbhep0;
	length cycle $10 lbtest $200;
    set source.lbhep(keep=edc_treenodeid edc_entrydate subject visit lbcat lbtmunk lbcode lbtest
                            lbnd lborres lborreso seq lbdt lbtm);

    %subject;
	
	length lbtestcd $8;
    label lbtestcd = 'Lab Test Code';
    lbtestcd = put(lbtest, $lbtestcd.); ** test code to be used as variable name after transpose;

    length lbdtc $20;
    label lbdtc = 'Collection Date';
    %ndt2cdt(ndt=lbdt, cdt=lbdtc);
    drop lbdt;


    ** combine "unknown" into "Collection Time";
    length lbtmc $10;
    label lbtmc = 'Collection Time';
    %ntime2ctime(ntime=lbtm, ctime=lbtmc);
    if lbtmunk > ' ' and lbtmc > ' ' then put "ERR" "OR: " LBTMUNK = +3 LBTMC = ;
    if lbtmunk > ' ' then lbtmc = 'Unknown';
    drop lbtm lbtmunk;
    
    
    length lborres2 $255;
    label lborres2 = 'Result';
    if lbnd > ' ' then lborres2 = 'Not Done';
    else if strip(lborres) = 'Other' and lborreso ^='' then lborres2 = strip(lborreso)||" (Other Result)";
	else if strip(lborres) ^= '' and lborreso ^='' then lborres2 = strip(lborres)||", "||strip(lborreso)||" (Other Result)";
	else lborres2 = lborres;
    drop lborres lbnd;

    cycle = cycle; ** in case that cycle is added in the furture.;
	%visit;

    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;

    ** variable that will be kept but will not be displayed;
    rename lbcat = __lbcat;
run;

data lbhep1;
    length subject $13 rfstdtc $10;
    length sex $6 __age 8;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        declare hash h2 (dataset:'pdata.dm');
        rc2 = h2.defineKey('subject');
        rc2 = h2.defineData('sex','__age');
        rc2 = h2.defineDone();
        call missing(subject, rfstdtc, sex, __age);
    end;
    set lbhep0;
    rc = h.find();
    rc2 = h2.find();
    %concatdy(lbdtc);
    drop rc rc2;
run;

proc sort data = lbhep1; by subject lbdtc lbtmc visit2 lbcode lbtestcd; run;

proc transpose data = lbhep1 out = t_lbhep0(drop=_name_ _label_);
    by subject lbdtc lbtmc visit2 lbcode __edc_treenodeid __edc_entrydate ; 
    id lbtestcd;
    idlabel lbtest;
    var lborres2;
run;

proc sort data = t_lbhep0; by subject lbdtc; run;

data out.lbhep(label = 'Hepatitis Serologies (Local Lab)');
	keep __edc_treenodeid __edc_entrydate subject lbdtc lbtmc visit2 lbcode hepb1 hepb2 hepb3 hepc;
	retain __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbtmc lbcode hepb1 hepb2 hepb3 hepc;
	set t_lbhep0;
run;
