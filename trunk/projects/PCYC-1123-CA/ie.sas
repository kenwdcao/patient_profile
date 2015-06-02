/*********************************************************************
 Program Nmae: IE.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/14
 __________________________________________________________________
 Modification History:


*********************************************************************/

%include '_setup.sas';

data ie0;
    set source.ie;
    keep edc_treenodeid site subject siteloc visit iecat ieprot  ietestcd ietest ieinc ieexc ieyn 
         ieprota iedt ieprotra  ierdt ieryn edc_entrydate ;	 
    %subject;
    rename EDC_TREENODEID = __EDC_TREENODEID;
    rename EDC_ENTRYDATE = __EDC_ENTRYDATE;
run;


/* one record per subject Informed Consen */
data ie1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set ie0(keep=iecat __edc_treenodeid __edc_entrydate subject ieprot ieprota iedt);
    where iecat='Inform Consent';
    rc = h.find();

    ** Informed Consent Signature Date Signed;
    length iedtc $20;
    label iedtc = 'First Informed Consent Signature Date';
    %ndt2cdt(ndt=iedt, cdt=iedtc);
    rc = h.find();
    %concatDY(iedtc);
    drop iedt rc;

    ** Protocol Version;
	if ieprot="Amendment (specify)" and ieprota^=. then ieprot="Amendment"  || ' ' || strip(put(ieprota, best.));
	else ieprot=ieprot;
    drop ieprota;
run;


/*one record per subject Re-Consent*/
data ie1_;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set ie0(keep=iecat subject ieprotra ierdt ieryn);
    where iecat = 'Subject Re-Consent' ;
   drop iecat;
    rc = h.find();

    ** Re-Consent Date to this Protocol Version**;
    length ierdtc $20;
    label ierdtc = 'Re-Consent Date to this Protocol Version';
    %ndt2cdt(ndt=ierdt, cdt=ierdtc);
    %concatDY(ierdtc);
    drop ierdt rc;
run;


proc sort data = ie0 out = ie2(keep=__edc_treenodeid __edc_entrydate subject siteloc ietestcd ietest  ierdt ieyn ieinc ieexc);
    by subject ietestcd;
    where iecat ="INCLUSION" or iecat="EXCLUSION";
run;



/* one record per IETEST part */
data ie3;
    set ie2;
    by subject;

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

    if ietestcd =: 'EX' and ieexc = 'N/A' then 
        _ieexcna = ifc(_ieexcna > ' ' , strip(_ieexcna)||', '||strip(ietestcd), ietestcd);
    else if ietestcd =: 'IN' and ieinc = 'N/A' then 
        _ieincna= ifc(_ieincna > ' ' , strip(_ieincna)||', '||strip(ietestcd), ietestcd);

    if last.subject;

    ** Combine _IEINC/_IEEXC and _IEINCNA/_IEEXCNA;
    length _ieviolate $255 _iena $255;
    label _ieviolate = 'I/E Violation';
    label _iena = 'I/E Not Applicable';
    _ieviolate = _ieinc;
    if _ieviolate > ' ' and  _ieexc > ' ' then _ieviolate = strip(_ieviolate)||', '||_ieexc;
    else if _ieexc > ' ' then  _ieviolate = _ieexc;
    
    _iena = _ieincna;
    if _iena > ' ' and  _ieexcna > ' ' then _iena = strip(_iena)||', '||_ieexcna;
    else if _ieexcna > ' '  then _iena = _ieexcna;
    keep subject ieyn siteloc _ieviolate _iena ;
run;


proc sort data=ie1; by subject; run;
proc sort data=ie1_ out=ie11_ nodupkey; by _all_; run;

data ie4;
    merge ie1 ie11_ ie3;
        by subject;
run;


data pdata.ie1(label='Informed Consent');
    retain __edc_treenodeid __edc_entrydate subject siteloc ieprot iedtc ieyn 
           _ieviolate _iena;
    keep   __edc_treenodeid __edc_entrydate subject siteloc ieprot iedtc ieyn 
           _ieviolate _iena;
    set ie4;
    label ieprot = 'Protocol Version the Subject First Consent to';
run;


data pdata.ie2(label='Subject Re-Consent');
    retain __edc_treenodeid __edc_entrydate subject ieryn ieprotra ierdtc;     
    keep   __edc_treenodeid __edc_entrydate subject ieryn ieprotra ierdtc;      
    set ie4;
	label ieryn = 'Re-consented to Later Versions of the Protocol';
   if ieryn^="";
run;
