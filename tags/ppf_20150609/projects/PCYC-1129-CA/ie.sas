/*********************************************************************
 Program Nmae: ie.sas
  @Author: Yuxiang Ni
  @Initial Date: 2015/04/23
 

 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/04/30: Split IE into Informed Consent and Inclusion
                        /Exclusion Criteria

*********************************************************************/

%include '_setup.sas';

data s_ie;
    length  subject $13 __rfstdtc $10 iedtc ieendtc $20;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
    length ORRES $200;
    set source.ie;
    
    %subject;

    if not missing(IEINC) then ORRES = strip(IEINC);
    else if not missing(IEEXC) then ORRES = strip(IEEXC);

    iedtc  = put(IEDT,yymmdd10.);
    ieendtc = put(IEENDT,yymmdd10.);

    %ndt2cdt(ndt=iedt, cdt=iedtc);
    %ndt2cdt(ndt=ieendt, cdt=ieendtc);

    rc = h.find();

    %concatdy(iedtc);
    %concatdy(ieendtc);

    rename EDC_TreenodeID = __EDC_TreenodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
run;

proc sort data=s_ie out = iec;
    by subject ietestcd;
    where (IETESTCD =: 'EX' and orres = 'Yes') or (IETESTCD =: 'IN' and orres = 'No') or orres = 'NA';
run;


data pdata.ie(label='Inclusion/Exclusion Criteria Not Met or Not Applicable');
    retain __EDC_TreenodeID __EDC_EntryDate SUBJECT IETESTCD IETEST ORRES;
    keep __EDC_TreenodeID __EDC_EntryDate SUBJECT IETESTCD IETEST ORRES;
    set iec;
    label orres = 'Result';
run;

proc sort data=s_ie out=ic;
    by subject ietestcd;
    where ietestcd = ' ';
run;

data pdata.ic(label="Informed Consent");
  retain __EDC_TreenodeID __EDC_EntryDate SUBJECT IEINT IEPROT IEPROTA IEDTC IEMMYN IEENDTC;
  keep __EDC_TreenodeID __EDC_EntryDate SUBJECT IEINT IEPROT IEPROTA IEDTC IEMMYN IEENDTC;
  set ic;
  
  label  IEDTC = "First Informed Consent Signature Date";
  label  IEENDTC = "Date of Approval";
  label  IEPROTA = "If Amendment, specify number";
run;
