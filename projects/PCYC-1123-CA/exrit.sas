/*********************************************************************
 Program Nmae: EXRIT.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/13
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data exrit1;
    length subject $13 rfstdtc exdisc_ $10 exdtc exsttmc exentmc $20  exrea exrstr $255;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
   
    set source.exrit(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
     label cycle = 'Cycle';
      %subject;

    ** Dose Date;
    label exdtc = 'Dose Date';
    %ndt2cdt(ndt=EXSTDT, cdt=exdtc);
    rc = h.find();
    %concatDY(exdtc);

    ** Infusion Time;
    label exsttmc = 'Infusion Start Time';
    label exentmc = 'Infusion Stop Time';
    %ntime2ctime(ntime=exsttm, ctime=exsttmc);
    %ntime2ctime(ntime=exentm, ctime=exentmc);

    ** Put dose unit into variable label;
    label exdose = 'Dose Intended#(mg)';
    label exadose = 'Dose Administered#(mg)';

    ** If No, specify reason;
    length exreas_ $255;
    label exreas_ = 'If No, specify reason';
    exreas_ = exreas;
    if aenumadm > . then exreas_ = strip(exreas_)||': '||strip(vvaluex('aenumadm'));
    if exreaso ^= ' ' then exreas_ = strip(exreas_)||': '||exreaso;


    length EXREASAD_ $255;
    label exreasad_ = 'If Dose Administered is not the same as the Dose Intended, provide reason';
    EXREASAD_ = EXREASAD;
    if AENUMSPL > ' ' then EXREASAD_ = strip(EXREASAD_)||': '||AENUMSPL;
    if EXREASAO > ' ' then EXREASAD_ = strip(EXREASAD_)||': '||EXREASAO;



    
    exdisc_=ifc(exdisc=1,'Yes','');
     label exdisc_='Rituximab was Permanently Discontinued';
     
    ***reason for not same as dose intended**;
     if AENUMSPL^='' then exrea=cat(strip(exreasad),': ',strip(AENUMSPL));
        else  if exreasao^='' then exrea=cat(strip(exreasad),': ',strip(exreasao));
        else exrea=strip(exreasad);
         label exrea='Reason Dose Administrated not the same as Dose Intended';

    *********questions for yes/no**;
     label  exinfrel='Did the subject have an infusion related reaction';
     label exrstr='Was study drug re-started and If drug was restarted, what happened?';
     exrstr=ifc(exrstres^='',cat(strip(exrestr),', ',strip(exrstres)),strip(exrestr));

run;


proc sort data = exrit1; by subject exdtc exsttmc exentmc ; run;

/*
%let k1=%str( __edc_treenodeid __edc_entrydate excat subject cycle exyn_ exdisc_ exdtc 
     exsttmc exentmc  exdose exadose  exlot );

%let k2=%str( __edc_treenodeid __edc_entrydate excat subject cycle exyn_ exdisc_ exdtc
             exrea expredos exinfrel exinfint exrstr);
*/

data pdata.exrit1(label='In-Clinic Administration of Rituximab IV');
    retain __edc_treenodeid __edc_entrydate excat subject cycle exyn exreas_  exdtc exsttmc exentmc exdose exadose exlot;
    keep __edc_treenodeid __edc_entrydate excat subject cycle exyn exreas_  exdtc exsttmc exentmc exdose exadose exlot;

    set exrit1;
    rename excat = __excat;

    label exdose = 'Dose Intended#(mg)';
    label exadose = 'Dose Administered#(mg)';


run;



data pdata.exrit2(label='In-Clinic Administration of Rituximab IV (Continued)');
    retain  __edc_treenodeid __edc_entrydate excat subject cycle exreasad_ EXPREDOS EXINFREL EXINFINT EXRESTR EXRSTRES;
    keep  __edc_treenodeid __edc_entrydate excat subject cycle exreasad_ EXPREDOS EXINFREL EXINFINT EXRESTR EXRSTRES;
    set exrit1;
    rename excat = __excat;

    label EXPREDOS = 'Were premedications administered?';
    label EXINFREL = 'Did the subject have an infusion related reaction?';
    label EXINFINT = 'Was infusion interrupted?';
    label EXRESTR = 'If infusion was interrupted, was study drug re-started?';
    label EXRSTRES = 'If drug was restarted, what happened when study drug was re-started?';

run;
