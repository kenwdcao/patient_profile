/********************************************************************************
 Program Nmae: LBBIO.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/25
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/03/10: Sort dataset by date.
********************************************************************************/

%include '_setup.sas';

data lbbio0;
    set source.lbbio(keep=EDC_TreeNodeID EDC_EntryDate subject lbdt lbtm lbgrnyn lbyelyn lbrefid cycle visit seq lbtmunk);
    %subject;

    length lbdtc $20;
    label lbdtc = 'Collection Date';
    %ndt2cdt(ndt=lbdt, cdt=lbdtc);
    drop lbdt;

    length lbtmc $10;
    label lbtmc = 'Collection Time';
    %ntime2ctime(ntime=lbtm, ctime=lbtmc);
    drop lbtm;

    ** combine "unknown" into "Collection Time";
    length lbtmc $10;
    label lbtmc = 'Collection Time';
    %ntime2ctime(ntime=lbtm, ctime=lbtmc);
    if lbtmunk > ' ' and lbtmc > ' ' then put "ERR" "OR: " LBTMUNK = +3 LBTMC = ;
    if lbtmunk > ' ' then lbtmc = 'Unknown';
    drop lbtm lbtmunk;
    
    %visit;
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename EDC_EntryDate = __EDC_EntryDate;
run;


data lbbio1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set lbbio0;
    rc = h.find();
    %concatdy(lbdtc);
    drop rc;
run;

proc sort data = lbbio1; by subject lbdtc; run;


data pdata.lbbio(label='Biomarker Sample (Central Lab)');
    keep __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbtmc lbrefid lbgrnyn lbyelyn;
    retain __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbtmc lbrefid lbgrnyn lbyelyn;
    set lbbio1;

    label lbrefid = 'Accession Number';
    label lbgrnyn = 'Was NA Heparin Green top tube (Flow Cytometry) collected?';
    label lbyelyn = 'Was ACD Yellow top tube (Biomarker) collected?';
run;
