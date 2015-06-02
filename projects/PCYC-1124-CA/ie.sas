/*********************************************************************
 Program Nmae: IE.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/04: Combine _IEINC/_IEEXC and _IEINCNA/_IEEXCNA.

*********************************************************************/

%include '_setup.sas';

data ie0;
    set source.ie;
    keep edc_treenodeid site subject visit iecat ieint ieprot ietestcd ietest ieinc ieexc iemmyn 
         iepart ielen ieprota iedt ieendt edc_entrydate ;
    rename EDC_TREENODEID = __EDC_TREENODEID;
    rename EDC_ENTRYDATE = __EDC_ENTRYDATE;
run;

/* one record per subject part */
data ie1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set ie0(keep=iecat __edc_treenodeid __edc_entrydate subject ieint ieprot ieprota iedt iemmyn ieendt iepart ielen);
    where iecat = ' ';
    drop iecat;

    %subject;

    rc = h.find();

    ** Informed Consent Signature Date Signed;
    length iedtc $20;
    label iedtc = 'First Informed Consent Signature Date';
    %ndt2cdt(ndt=iedt, cdt=iedtc);
    rc = h.find();
    %concatDY(iedtc);
    drop iedt rc;


    ** Date of Approval;
    length ieendtc $20;
    label ieendtc = 'Date of Approval';
    %ndt2cdt(ndt=ieendt, cdt=ieendtc);
    %concatDY(ieendtc);
    drop ieendt rc;


    ** Protocol Version;
    ieprot = strip(ieprot) || ' ' || ifc(ieprota>., strip(vvaluex('ieprota')), ' ');
    drop ieprota;

run;

proc sort data = ie0 out = ie2(keep=__edc_treenodeid __edc_entrydate subject ietestcd ietest ieinc ieexc);
    by subject ietestcd;
    where iecat > ' ';
run;

/* one record per IETEST part */
data ie3;
    
    set ie2;
    by subject;

    %subject;

    length _ieinc $255 _ieexc $255;
    retain _ieinc _ieexc;
    label _ieinc = 'Inclusion Criteria Not Met';
    label _ieexc = 'Exclusion Criteria Met';

    length _ieincna $255 _ieexcna $255;
    retain _ieincna _ieexcna;
    label _ieincna = 'Inclusion Criteria Not Applicable';
    label _ieexcna = 'Exclusion Criteria Not Applicable';

    if first.subject then do;
        call missing(_ieinc, _ieexc, _ieincna, _ieexcna);
    end;

    if ietestcd =: 'EX' and ieexc = 'Yes' then 
        _ieexc = ifc(_ieexc > ' ' , strip(_ieexc)||', '||strip(ietestcd), ietestcd);
    else if ietestcd =: 'IN' and ieinc = 'No' then 
        _ieinc= ifc(_ieinc > ' ' , strip(_ieinc)||', '||strip(ietestcd), ietestcd);

    if ietestcd =: 'EX' and ieexc = 'NA' then 
        _ieexcna = ifc(_ieexcna > ' ' , strip(_ieexcna)||', '||strip(ietestcd), ietestcd);
    else if ietestcd =: 'IN' and ieinc = 'NA' then 
        _ieincna= ifc(_ieincna > ' ' , strip(_ieincna)||', '||strip(ietestcd), ietestcd);

    if last.subject;

    ** Ken Cao on 2015/03/04: Combine _IEINC/_IEEXC and _IEINCNA/_IEEXCNA;
    length _ieviolate $255 _iena $255;
    label _ieviolate = 'I/E Violation';
    label _iena = 'I/E Not Applicable';
    _ieviolate = _ieinc;
    if _ieviolate > ' ' and  _ieexc > ' ' then _ieviolate = strip(_ieviolate)||', '||_ieexc;
    else if _ieexc > ' ' then  _ieviolate = _ieexc;
    
    _iena = _ieincna;
    if _iena > ' ' and  _ieexcna > ' ' then _iena = strip(_iena)||', '||_ieexcna;
    else if _ieexcna > ' '  then _iena = _ieexcna;

    

    keep subject _ieviolate _iena ;
run;


proc sort data=ie1; by subject; run;

data ie4;
    merge ie1 ie3;
        by subject;
run;


data pdata.ie(label='Informed Consent');
    retain __edc_treenodeid __edc_entrydate subject ieint ieprot iedtc iemmyn ieendtc iepart ielen 
           _ieviolate _iena;
    keep   __edc_treenodeid __edc_entrydate subject ieint ieprot iedtc iemmyn ieendtc iepart ielen 
           _ieviolate _iena;
    set ie4;

    label ieprot = 'Protocol Version the Subject First Consent to';
    label iemmyn = 'Enrollment Approval Obtained by the Sponsor';
    label iepart = 'Part the Subject Enrolled';
    label ielen = 'If Part 1, Specify Lenalidomide Dose Level';
run;
