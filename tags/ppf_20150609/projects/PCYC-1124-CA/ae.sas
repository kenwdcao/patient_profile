/*********************************************************************
 Program Nmae: AE.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/23: Include SOC and PT with medical history terms.

*********************************************************************/

%include '_setup.sas';

data ae0;
    set source.ae;
    keep EDC_TREENODEID EDC_ENTRYDATE SUBJECT AETERM AESER AEDLT AESTDD AESTMM AESTYY
         AEOUT AEENDD AEENMM AEENYY AETOXGR AERELI AERELL AERELE AESEQ AENUM AEACN:
         AEDECOD AEBODSYS;
    rename EDC_TREENODEID = __EDC_TREENODEID;
    rename EDC_ENTRYDATE = __EDC_ENTRYDATE;
    rename aeseq = __aeseq;
    where AEYN = ' ';
run;

%let dlm = %str(,); ** delimter to separate multiple action taken;

data ae1;
    set ae0;
    %subject;


    length _aeterm $512;
    /*
    label _aeterm = "&escapechar{style [foreground=#000000]System Organ Class}/#
&escapechar{style [foreground=#000000]Preferred Term}/#
&escapechar{style [foreground=#000000]Verbatim Term}";


    _aeterm = "&escapeChar{style [foreground=#000000]"||strip(aebodsys)||'}/'||"&escapeChar.n"||
              "&escapeChar{style [foreground=#000000]"||strip(aedecod)||'}/'||"&escapeChar.n"||
              "&escapeChar{style [foreground=#000000]"||strip(aeterm)||'}';
    */

    label _aeterm = "System Organ Class/#Preferred Term/#Verbatim Term";

    _aeterm = strip(aebodsys)||"/&escapeChar.n"||
              strip(aedecod) ||"/&escapeChar.n"||
              strip(aeterm);

    ** AESTDTC and AEENDTC;
    length aestdtc aeendtc $20;
    label aestdtc = 'Start Date';
    label aeendtc = 'End Date';
    %concatDate(year=aestyy, month=aestmm, day=aestdd, outdate=aestdtc);
    %concatDate(year=aeenyy, month=aeenmm, day=aeendd, outdate=aeendtc);
    drop aestyy aestmm aestdd aeenyy aeenmm aeendd;
    
    __st = 0; ** used for extracting information from action taken variables;

    ** action taken with Ibrutinib;
    length _aeacni $255;
    label _aeacni = 'Action Taken with Ibrutinib';
    array aeacni{*} aeacni:;
    __st = length("Ibrutinib Action Taken") + 2;
    do i = 1 to dim(aeacni);
        if aeacni[i] = ' ' then continue;
        _aeacni = ifc(_aeacni>' ', strip(_aeacni)||"&dlm "||substr(vlabel(aeacni[i]),__st), substr(vlabel(aeacni[i]),__st));
    end;
    drop aeacni:;

    ** action taken with Lenalidom;
    length _aeacnl $255;
    label _aeacnl = 'Action Taken with Lenalidom';
    array aeacnl{*} aeacnl:;
    __st = length("Lenalidom. Action Taken") + 2;
    do i = 1 to dim(aeacnl);
        if aeacnl[i] = ' ' then continue;
        _aeacnl = ifc(_aeacnl>' ', strip(_aeacnl)||"&dlm "||substr(vlabel(aeacnl[i]),__st), substr(vlabel(aeacnl[i]),__st));
    end;
    drop aeacnl:;

    ** action taken with Rituximab;
    length _aeacnr $255;
    label _aeacnr = 'Action Taken with Rituximab';
    array aeacnr{*} aeacnr:;
    __st = length("Ibrutinib Action Taken") + 2;
    do i = 1 to dim(aeacnr);
        if aeacnr[i] = ' ' then continue;
        _aeacnr = ifc(_aeacnr>' ', strip(_aeacnr)||"&dlm "||substr(vlabel(aeacnr[i]),__st), substr(vlabel(aeacnr[i]),__st));
    end;
    drop aeacnr:;

    ** action taken with Etoposide;
    length _aeacne $255;
    label _aeacne = 'Action Taken with Etoposide';
    array aeacne{*} aeacne:;
    __st = length("Etoposide Action Taken") + 2;
    do i = 1 to dim(aeacne);
        if aeacne[i] = ' ' then continue;
        _aeacne = ifc(_aeacne>' ', strip(_aeacne)||"&dlm "||substr(vlabel(aeacne[i]),__st), substr(vlabel(aeacne[i]),__st));
    end;
    drop aeacne:;

    ** action taken with Prednisone;
    length _aeacnp $255;
    label _aeacnp = 'Action Taken with Prednisone';
    array aeacnp{*} aeacnp:;
    __st = length("Prednisone Action Taken") + 2;
    do i = 1 to dim(aeacnp);
        if aeacnp[i] = ' ' then continue;
        _aeacnp = ifc(_aeacnp>' ', strip(_aeacnp)||"&dlm "||substr(vlabel(aeacnp[i]),__st), substr(vlabel(aeacnp[i]),__st));
    end;
    drop aeacnp:;


    ** action taken with Doxorub;
    length _aeacnd $255;
    label _aeacnd = 'Action Taken with Doxorub';
    array aeacnd{*} aeacnd:;
    __st = length("Doxorub. Action Taken") + 2;
    do i = 1 to dim(aeacnd);
        if aeacnd[i] = ' ' then continue;
        _aeacnd = ifc(_aeacnd>' ', strip(_aeacnd)||"&dlm "||substr(vlabel(aeacnd[i]),__st), substr(vlabel(aeacnd[i]),__st));
    end;
    drop aeacnd:;

    ** action taken with Cyclophosphamide;
    length _aeacnc $255;
    label _aeacnc = 'Action Taken with Cyclophosphamide';
    array aeacnc{*} aeacnc:;
    __st = length("Cycloph. Action Taken") + 2;
    do i = 1 to dim(aeacnc);
        if aeacnc[i] = ' ' then continue;
        _aeacnc = ifc(_aeacnc>' ', strip(_aeacnc)||"&dlm "||substr(vlabel(aeacnc[i]),__st), substr(vlabel(aeacnc[i]),__st));
    end;
    drop aeacnc:;

    ** action taken with Vincris;
    length _aeacnv $255;
    label _aeacnv = 'Action Taken with Vincris';
    array aeacnv{*} aeacnv:;
    __st = length("Vincris. Action Taken") + 2;
    do i = 1 to dim(aeacnv);
        if aeacnv[i] = ' ' then continue;
        _aeacnv = ifc(_aeacnv>' ', strip(_aeacnv)||"&dlm "||substr(vlabel(aeacnv[i]),__st), substr(vlabel(aeacnv[i]),__st));
    end;
    drop aeacnv:;

    ** action taken Other;
    if aeacnoth > ' ' then aeacnoth = 'Other: '||aeacnoth;
    length _aeacno $255;
    label _aeacno = 'Action Taken Other';
    array aeacno{*} aeacno:;
    __st = length("Action Taken Other") + 2;
    do i = 1 to dim(aeacno);
        if aeacno[i] = ' ' then continue;
        else if vname(aeacno[i]) = 'AEACNO05' then continue; ** skip AEACNO05;
        _aeacno = ifc(_aeacno>' ', strip(_aeacno)||"&dlm "||substr(vlabel(aeacno[i]),__st), substr(vlabel(aeacno[i]),__st));
    end;
    drop aeacno:;

    drop i __st;
run;

data ae2; 
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set ae1; 
    rc = h.find();
    %concatdy(aestdtc); 
    %concatdy(aeendtc); 
    drop rc;
run;

proc sort data = ae2; by subject aestdtc aeendtc; run;

data pdata.ae1(label='Adverse Event');
    retain __edc_treenodeid __edc_entrydate subject aenum _aeterm aeser aedlt aestdtc aeout aeendtc aetoxgr 
            aereli aerell aerele ;
    keep __edc_treenodeid __edc_entrydate subject aenum _aeterm aeser aedlt aestdtc aeout aeendtc aetoxgr 
            aereli aerell aerele;
    set ae2;

    label aenum = 'Record Number';
    label aeterm = 'Adverse Event';
    label aeser = 'SAE?';
    label aedlt = 'DLT?';
    label aeout = 'Outcome';
    label aereli = 'Ibrutinib';
    label aerell = 'Lenalidomide';
    label aerele = 'EPOCH-R';
run;

data pdata.ae2(label='Adverse Event (Action Taken)');
    retain __edc_treenodeid __edc_entrydate subject aenum _aeterm _aeacni _aeacnl _aeacnr _aeacne _aeacnp _aeacnd 
           _aeacnc _aeacnv _aeacno ;
    keep __edc_treenodeid __edc_entrydate subject aenum _aeterm  _aeacni _aeacnl _aeacnr _aeacne _aeacnp _aeacnd 
           _aeacnc _aeacnv _aeacno ;
    set ae2;

    label aenum = 'Record Number';
    label aeterm = 'Adverse Event';
    label _aeacni = 'Ibrutinib';
    label _aeacnl = 'Lenalidomide';
    label _aeacnr = 'Rituximab';
    label _aeacne = 'Etoposide';
    label _aeacnp = 'Prednisone';
    label _aeacnd = 'Doxorubicin';
    label _aeacnc = 'Cyclophosphamide';
    label _aeacnv = 'Vincristine';
    label _aeacno = 'Other';
run;
