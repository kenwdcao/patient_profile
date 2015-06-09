/*********************************************************************
 Program Nmae: ae.sas
  @Author: Ken Cao
  @Initial Date: 2015/04/08
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data ae0;
    set source.ae;
    %subject;
    keep EDC_TreeNodeID SUBJECT AETERM AESER AENEWM AEACNOTH AEMODIFY AELLT AEDECOD AEBODSYS
         AEHLT AEHLGT AESEQ AENUM AESTDD AESTMM AESTYY AEOUT AEENDD AEENMM AEENYY AESEV AEREL AEACN03 
         AEACN04 AEACN05 AEACN01 AERELL AEACN06 AEACN07 AEACN08 AEACN09 AERELR AEACN10 AEACN11 AEACN12 
         AEACNO02 AEACNO03 AEACNO04 AEACNO05 AEACNO01 EDC_EntryDate AESOC ;
    where aeyn = ' ';
run;

data aeyn;
    set source.ae;
    keep subject aeyn;
    where aeyn ^= ' ';
run;

data ae1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set ae0;

    length aestdtc $20 aeendtc $20;
    %concatDate(year=aestyy, month=aestmm, day=aestdd, outdate=aestdtc);
    %concatDate(year=aeenyy, month=aeenmm, day=aeendd, outdate=aeendtc);
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(aestdtc);
    %concatDY(aeendtc);
    drop aestyy aestmm aestdd aeenyy aeenmm aeendd;

    length _aeterm $512;
    _aeterm = strip(aebodsys)||"/&escapechar.n"||strip(aedecod)||"/&escapechar.n"||strip(aeterm);


    ** Action taken;
    length _aeacnb _aeacnl _aeacnr _aeacno $255;
    label  aeacn06 = 'Action Taken Dose Reduced Lenalidomide';
    label aeacno05 = 'Action Taken Other Other Specify';

    array acnbtk{*} aeacn03 aeacn04 aeacn05 aeacn01;
    array acnlen{*} aeacn06 aeacn07 aeacn08 aeacn09;
    array acnrit{*} aeacn10 aeacn11 aeacn12;
    array acnoth{*} aeacno02 aeacno03 aeacno04 aeacno05 aeacno01;

    __len = length('Action Taken');

    do i = 1 to dim(acnbtk);
        if acnbtk[i] = . then continue;
        _aeacnb = ifc(_aeacnb = ' ', substr(vlabel(acnbtk[i]), __len + 2), 
              strip(_aeacnb)||', '||substr(vlabel(acnbtk[i]), __len + 2));
    end;

    do i = 1 to dim(acnlen);
        if acnlen[i] = . then continue;
        _aeacnl = ifc(_aeacnl = ' ', substr(vlabel(acnlen[i]), __len + 2, length(vlabel(acnlen[i]))-__len-length('Lenalidomide')-1), 
               strip(_aeacnl)||', '||substr(vlabel(acnlen[i]), __len + 2, length(vlabel(acnlen[i]))-__len-length('Lenalidomide')-1));
    end;

    do i = 1 to dim(acnrit);
        if acnrit[i] = . then continue;
        _aeacnr = ifc(_aeacnr = ' ', substr(vlabel(acnrit[i]), __len + 2, length(vlabel(acnrit[i]))-__len-length('Rituximab')-1), 
               strip(_aeacnr)||', '||substr(vlabel(acnrit[i]), __len + 2, length(vlabel(acnrit[i]))-__len-length('Rituximab')-1));
    end;

    __len = length('Action Taken Other');

    do i = 1 to dim(acnoth);
        if acnoth[i] = . then continue;
        _aeacno = ifc(_aeacno = ' ', substr(vlabel(acnoth[i]), __len + 2), 
              strip(_aeacno)||', '||substr(vlabel(acnoth[i]), __len + 2));
    end;

    drop aeacn: i;
run;

proc sort data=ae1; by subject aestdtc aeendtc aeterm ;run;

data pdata.ae1(label='Adverse Event');

    retain EDC_TreeNodeID EDC_EntryDate subject aenum aeseq _aeterm aeterm aedecod aebodsys aeser aenewm aestdtc aeout aeendtc aerel aerell aerelr
           aemodify aellt  aehlt aehlgt aesoc;
    keep EDC_TreeNodeID EDC_EntryDate subject aenum aeseq _aeterm aeterm aedecod aebodsys aeser aenewm aestdtc aeout aeendtc aerel aerell aerelr
           aemodify aellt  aehlt aehlgt aesoc;

    set ae1;

    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename          aeseq = __aeseq;
    rename       aemodify = __aemodify;
    rename          aellt = __aellt;
    rename          aehlt = __aehlt;
    rename         aehlgt = __aehlgt;
    rename          aesoc = __aesoc;
    rename         aeterm = __aeterm;
    rename        aedecod = __aedecod;
    rename       aebodsys = __aebodsys;

    label _aeterm = "System Organ Class/&splitchar.Preferred Term/&splitchar.Verbatim Term";
    label aestdtc = 'Start Date';
    label   aeout = 'Outcome';
    label aeendtc = 'End Date';
    label   aerel = 'Ibrutinib@:Relationship to'; 
    label  aerell = 'Lenalidomide@:Relationship to';
    label  aerelr = 'Rituximab@:Relationship to';

run;


data pdata.ae2(label='Adverse Event (Continued)');
    retain EDC_TreeNodeID EDC_EntryDate subject aenum aeseq _aeterm aeterm aedecod aebodsys aesev _aeacnb _aeacnl _aeacnr _aeacno; 
    keep EDC_TreeNodeID EDC_EntryDate subject aenum aeseq _aeterm aeterm aedecod aebodsys aesev _aeacnb _aeacnl _aeacnr _aeacno; 
    set ae1;
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename          aeseq = __aeseq;
    rename         aeterm = __aeterm;
    rename        aedecod = __aedecod;
    rename       aebodsys = __aebodsys;

    label _aeterm = "System Organ Class/&splitchar.Preferred Term/&splitchar.Verbatim Term";
    label _aeacnb = "Action Taken with Ibrutinib";
    label _aeacnl = "Action Taken with Lenalidomide";
    label _aeacnr = "Action Taken with Rituximab";
    label _aeacno = "Other Action Taken";
	label aesev ="Toxicity Grade";
run;
