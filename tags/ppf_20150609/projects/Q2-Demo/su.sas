/*********************************************************************
 Program Nmae: SU.sas
  @Author: Yan Zhang
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/04: Display UNK and NULL for date value.
*********************************************************************/
%include "_setup.sas";

data su01;
    length sustdtc  suendtc $20;
    keep subject visit suscat  sustdtc  suendtc suongo suoccur __EDC_TreeNodeID __EDC_EntryDate;
    set source.su (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate));
    if suoccur ^= '';
    %subject;
    sustdd = '';
    suendd = '';
    %concatDateV2(year=sustyy, month=sustmm, day=sustdd, outdate=sustdtc);
    *put sustmm = __month= sustdtc=;
    %concatDateV2(year=suenyy, month=suenmm, day=suendd, outdate=suendtc);
    keep sust:;
    keep suen:;
    if sustdtc > ' ' then sustdtc = substr(sustdtc, 1, length(sustdtc) - length(scan(sustdtc,-1,'-')) - 1);
    if suendtc > ' ' then suendtc = substr(suendtc, 1, length(suendtc) - length(scan(suendtc,-1,'-')) - 1);
    suongo = put(suongo,$checked.);
run;

data su02;
    keep subject visit suscat  sutrt sudose sudosu sudosfrq __EDC_TreeNodeID __EDC_EntryDate;
    set source.su(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate));
    if sudose ^= '';
    %subject;
run;

proc sort data = su01; by subject visit suscat;run;
data pdata.su1(label = 'Tobacco and Alcohol Use History');
    retain __EDC_TreeNodeID __EDC_EntryDate subject suscat suoccur sustdtc  suendtc suongo ;
    keep __EDC_TreeNodeID __EDC_EntryDate subject suscat suoccur sustdtc  suendtc suongo  ;
    attrib
    sustdtc                      label = 'Date first started'
    suendtc                      label = 'Date of last use';
    set su01;
run;

proc sort data = su02; by subject visit suscat;run;
data pdata.su2(label = 'Tobacco and Alcohol Use History (Continued)');
    keep __EDC_TreeNodeID __EDC_EntryDate subject suscat  sutrt sudose sudosu sudosfrq ;
    retain __EDC_TreeNodeID __EDC_EntryDate subject suscat  sutrt sudose sudosu sudosfrq ;
    set su02;
run;
