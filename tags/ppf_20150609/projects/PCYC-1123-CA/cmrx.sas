/*********************************************************************
 Program Nmae: CMRX.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/09
 
 New CMRX.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/
%include "_setup.sas";


data cmrx0;
    set source.cmrx(rename=(edc_treenodeid=__edc_treenodeid  edc_entrydate=__edc_entrydate visit=__visit));
    %subject;     
run;

proc sort data=cmrx0; by subject  ;run;



************************;
data cmrx2;
    length tryn $60 trandtc rxtrtn cycle rxstdtc rxendtc rxprdtc $20 pdnles_ $500
     pdoth_ _pddetrm $255 subject $13 rfstdtc $10;

    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set cmrx0;
    rc = h.find();
    drop rc;

    if EDC_FormLabel^='Prior DLBCL Therapy Prompt';
    __rxcat=strip(rxcat);
    label __rxcat ='Prior DLBCL Treatment';


     array aa rxrgnumn  pdsinc ;
     array bb  $20 rxrgnumn_  pdsinc_;
     do over aa;
    
     bb=ifc(aa=1,'Yes','');
     end;

     label rxrgnumn_='Do not include in regimen count';
     label pdsinc_='Increase in size of existing lesion(s)@:Evidence for progressive disease';

    **combine transplant**;
    tryn=ifc(rxtrans='Yes',cat(strip(rxtrans),', ', strip(rxtrtyp)),strip(rxtrans));
    label tryn ='Was this regimen associated with a transplant?';

   ***date for transplant**;
    label trandtc = 'Date of Transplant';
    %concatDate(year=rxtryy, month=rxtrmm, day=rxtrdd, outdate=trandtc);
    %concatDY(trandtc);

    ****agent**;
   label RXGRID='Agent #';
   rxtrtn=ifc(rxtrtinv=1,'Yes','');
   label rxtrtn='Agent Name Investigational';

   **cycle no.**;
     cycle=ifc(rxcycnu=1,'NA/UNK',strip(put(rxcycn,best.)));
     label cycle='Number of Cycles';

      ** Prior DLBCL Treatment Start Date and End Date;
    label rxstdtc = 'Start Date';
    label rxendtc = 'End Date';
    %concatDate(year=rxstyy, month=rxstmm, day=rxstdd, outdate=rxstdtc);
    %concatDate(year=rxenyy, month=rxenmm, day=rxendd, outdate=rxendtc);
    %concatDY(rxstdtc);
    %concatDY(rxendtc);

   ** Date of Progression;
    label rxprdtc = 'Date of Progression';
    %concatDate(year=rxpryy, month=rxprmm, day=rxprdd, outdate=rxprdtc);
    %concatDY(rxprdtc);
    rxprdtc = ifc(rxprdtuk=1 or rxprdtna=1,'Unknown',strip(rxprdtc));

    ** New lesion(s), specify location(s);
    label pdnles_ = 'New lesion(s)@:Evidence for progressive disease';
    pdnles_ =ifc(pdnless ^='', strip(pdnless),'');
    if pdnless = ' ' and pdnles =1 then do;
        pdnles_ = 'New Lesion';
        put "WARN" "ING: New Lesion was checked, but location was not specified";
    end;


    ** Other (specify);
    label pdoth_ = 'Other@:Evidence for progressive disease';
    pdoth_ =ifc(pdoths ^='',strip(pdoths),'');
    if pdoth_ = ' ' and pdoth =1 then do;
        pdoth_ = 'Other';
        put "WARN" "ING: Other was checked, but no details specified";
    end;

    **  Combine "How was progression determined?" ;
    
    label _pddetrm = 'How was progression determined?';
    pdct_=ifc(pdct=1,'CT Scan','');
    pdpe_=ifc(pdpe=1,'Physical Exam','');
    pdbmbiop_=ifc(pdbmbiop=1,'Bone Marrow','');
    pdlnbiop_=ifc(pdlnbiop=1,'Lymph Node','');
    pdunk_=ifc(pdunk=1,'Unknown','');
    _pddetrm=strip(catx(', ', pdct_, pdpe_, pdbmbiop_, pdlnbiop_, pdunk_));

    length __rxgridn 8;
    __rxgridn = input(rxgrid, best.);
run;


proc sort data=cmrx2 nodupkey out=cmrx3;
    by subject rxrgnum __rxgridn;
    where __rxcat >  ' '  and rxtrt > ' ';
run;

proc sort data=cmrx2 nodupkey out=cmrx4;
    by subject rxrgnum;
    where __rxcat >  ' ';
run;


data pdata.cmrx1(label='Prior DLBCL Therapy Prompt');
    retain __EDC_TreeNodeID __EDC_EntryDate subject __visit rxyn rdyn psyn;
    keep __EDC_TreeNodeID __EDC_EntryDate subject __visit rxyn rdyn psyn;
    set cmrx0;
     if EDC_FormLabel='Prior DLBCL Therapy Prompt';
    label rxyn = 'Does the subject have any prior DLBCL related chemotherapy, immunotherapy, and/or stem cell transplant to report?';
    label rdyn = 'Does the subject have any prior DLBCL related radiation to report?';
    label psyn = 'Does the subject have any prior DLBCL related surgery to report?';
run;


data pdata.cmrx2(label='Prior DLBCL Treatment');
    retain __EDC_TreeNodeID __EDC_EntryDate subject __visit  __rxcat rxrgnum rxrgnumn_ rxtrans rxtrtyp  trandtc rxresp rxprdtc  _pddetrm PDSINC_ pdnles_ pdoth_;
    keep __EDC_TreeNodeID __EDC_EntryDate subject __visit  __rxcat rxrgnum rxrgnumn_ rxtrans rxtrtyp  trandtc rxresp rxprdtc  _pddetrm PDSINC_ pdnles_ pdoth_;
    set cmrx4;

    label rxtrans = 'Was this regimen associated with a transplant?';
    label rxtrtyp = 'Type@:If Yes, provide information';
    label trandtc = 'Date of Transplant@:If Yes, provide information';
run;

data pdata.cmrx3(label='Prior DLBCL Treatment (Continued)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject __visit  __rxcat rxrgnum   RXGRID rxtrt cycle rxtrtn  rxstdtc rxendtc;
    keep __EDC_TreeNodeID __EDC_EntryDate subject __visit  __rxcat rxrgnum   RXGRID rxtrt cycle rxtrtn  rxstdtc rxendtc;
    set cmrx3;
run;
