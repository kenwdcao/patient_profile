/*********************************************************************
 Program Nmae: ae.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/23
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data ae0;
   length subject $13;
    set source.ae_coded(rename =(EDC_TreeNodeID = __EDC_TreeNodeID  EDC_EntryDate = __EDC_EntryDate));
    %subject;   
run;

proc sort data=ae0; by subject; run;

data ae1;
    length  subject $13 __rfstdtc $10 aestdtc  aeendtc $20 _aeterm $512 _aeacnb    _aeacno $255;
   if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
    set ae0;
    where aeyn = ' ';
   rc = h.find();
    **date**;

   %concatDate(year=aestyy, month=aestmm, day=aestdd, outdate=aestdtc);
  %concatDate(year=aeenyy, month=aeenmm, day=aeendd, outdate=aeendtc);

    %concatDY(aestdtc);
    %concatDY(aeendtc);

    *****soc-pt-term****;
       _aeterm = strip(aebodsys)||"/&escapechar.n"||strip(aedecod)||"/&escapechar.n"||strip(aeterm);

    ** Action taken;
    label aeacno05 = 'Action Taken Other Other Specify';
    label aeacno04 = 'Action Taken HospitHospitalization / prolongation of hospitalization';
    label aeacnoth = 'If Other Action Taken, specify';

    array acnbtk{*} aeacni02-aeacni06 ;
    array acnother{*} aeacno02-aeacno05 aeacno01;

    __len = length('Ibrutinib Action Taken');

    do i = 1 to dim(acnbtk);
        if acnbtk[i] =''  then continue;
        acnbtk[i] = 'Yes';
        _aeacnb = ifc(_aeacnb = ' ', substr(vlabel(acnbtk[i]), __len + 2), 
              strip(_aeacnb)||', '||substr(vlabel(acnbtk[i]), __len + 2));
    end;

    __len = length('Action Taken Other');

    do i = 1 to dim(acnother);
        if acnother[i] =''  then continue;
        acnother[i] = 'Yes';
        _aeacno = ifc(_aeacno = ' ', substr(vlabel(acnother[i]), __len + 2), 
              strip(_aeacno)||', '||substr(vlabel(acnother[i]), __len + 2));
    end;
run;

data pdata.ae1(label='Adverse Events Prompt');
    retain __EDC_TreeNodeID __EDC_EntryDate subject aeyn;
    set ae0;
    where aeyn ^= ' ';
     label aeyn='Does subject have any adverse events to report?';
    keep __EDC_TreeNodeID __EDC_EntryDate subject aeyn;
run;

proc sort data=ae1; by subject aestdtc aeendtc aeterm ;run;

%let k1=%str(__EDC_TreeNodeID __EDC_EntryDate subject aenum aeseq _aeterm aeterm aedecod aebodsys 
             aeser aedlt  aestdtc aeout aeendtc AETOXGR aereli );

data pdata.ae2(label='Adverse Events');
         retain &k1;
         keep &k1;
         set ae1;
        attrib
    aestdtc    label='Start Date'
    aeendtc   label='End Date'
     _aeterm  label= "System Organ Class/&splitchar.Preferred Term/&splitchar.Verbatim Term"
    aeser       label='SAE?'
    aedlt         label='Check if this is a dose limiting toxicity (DLT)'
    aeout       label='Outcome'
    aetoxgr    label='Severity'
   aereli         label= 'Relationship to Ibrutinib';

    rename          aeseq = __aeseq;
    rename         aeterm = __aeterm;
    rename        aedecod = __aedecod;
    rename       aebodsys = __aebodsys;
run;


data pdata.ae3 (label='Adverse Events(Continued)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject aenum aeseq _aeterm aeterm aedecod aebodsys 
             AEACNI02 AEACNI03 AEACNI04 AEACNI05 AEACNI06
             AEACNO02 AEACNO03 AEACNO04 AEACNO05 AEACNO01
            aeacnoth  aellt  aehlt aehlgt aesoc; 
    keep __EDC_TreeNodeID __EDC_EntryDate subject aenum aeseq _aeterm aeterm aedecod aebodsys 
             AEACNI02 AEACNI03 AEACNI04 AEACNI05 AEACNI06
             AEACNO02 AEACNO03 AEACNO04 AEACNO05 AEACNO01
            aeacnoth  aellt  aehlt aehlgt aesoc; 
    set ae1;
    attrib
   _aeterm  label= "System Organ Class/&splitchar.Preferred Term/&splitchar.Verbatim Term"
   _aeacnb    label='Action Taken with Ibrutinib'
   _aeacno     label='Other Action Taken';

    rename          aeseq = __aeseq;
    rename         aeterm = __aeterm;
    rename        aedecod = __aedecod;
    rename       aebodsys = __aebodsys;
/*  rename       aemodify = __aemodify;*/
    rename          aellt = __aellt;
    rename          aehlt = __aehlt;
    rename         aehlgt = __aehlgt;
    rename          aesoc = __aesoc;


    label 
        AEACNI02 = 'Dose Not Changed@:Action Taken with Ibrutinib'
        AEACNI03 = 'Dose Reduced@:Action Taken with Ibrutinib'
        AEACNI04 = 'Drug Interrupted@:Action Taken with Ibrutinib'
        AEACNI05 = 'Drug Withdrawn@:Action Taken with Ibrutinib'
        AEACNI06 = 'Not Applicable@:Action Taken with Ibrutinib'

        AEACNO02 = 'Medication@:Other Action Taken'
        AEACNO03 = 'Non-drug therapy@:Other Action Taken'
        AEACNO04 = 'Hospitalization / prolongation of hospitalization@:Other Action Taken'
        AEACNO05 = 'Other (Specify)@:Other Action Taken'
        AEACNO01 = 'None@:Other Action Taken'
    ;
run;


