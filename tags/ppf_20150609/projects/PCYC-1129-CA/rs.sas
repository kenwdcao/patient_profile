/********************************************************************************
 Program Nmae: RS.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

data rs;
 length rsdtc  $20  subject $13 __rfstdtc $10;
    attrib 
  RSSKIN label ='Skin@:Individual Response Areas'
  RSEYE label ='Eye@:Individual Response Areas'
  RSMOUTH label ='Mouth@:Individual Response Areas'
  RSPLT label ='Platelet Count@:Individual Response Areas'
  RSGASTRO label ='Gastrointestinal@:Individual Response Areas'
  RSLIVER label ='Liver@:Individual Response Areas'
  RSLUNG label ='Lungs@:Individual Response Areas'
  RSRESP    label='Provide Investigator’s Overall Disease Assessment by protocol criteria'
  RSRESPNE    label='If Not Evaluable, specify reason' 
  RSCONFYN label='Are there any confounding factors that may impact ability to accurately assess this response?'

  RSCONGO label='Other@:Confounding Factors' 
  RSCONFIN label='Infection@:Confounding Factors' 
  RSCONFCM label ='Concomitant Medications@:Confounding Factors' 
  RSCONFSG label ='Surgery / Procedures@:Confounding Factors' 
  RSCONFGV label ='cGVHD Flare@:Confounding Factors' 

/*   _conf label='Confounding Factors'*/
   rsyn label='Were any Disease Progression (PD) and/or Unscheduled Response Evaluation Visits completed?'
   rseval label='Were any Post Treatment, Response Follow-Up Visits completed?';

    if _n_ = 1 then do;
       declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set source.rs(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
     %visit2;

	 ****date**;
   label rsdtc = 'Assessment Date';
    %ndt2cdt(ndt=rsdt, cdt=rsdtc);
    rc = h.find();
    %concatDY(rsdtc);

   ** confounding factors**;
	 array aa   RSCONFIN  RSCONFCM RSCONFSG  RSCONFGV RSCONGO;
	 do over aa;
	 if aa='Checked' then aa='Yes'; 
	 end;
/*    array con{*} RSCONFSG  RSCONGO  RSCONFIN  RSCONFCM  RSCONFGV;*/
  
/*    __len = length('Confounding Factors');*/
/**/
/*    do i = 1 to dim(con);*/
/*        if con[i] =' '  then continue;*/
/*        _conf = ifc(_conf = ' ', substr(vlabel(con[i]), __len + 2), */
/*              strip(_conf)||', '||substr(vlabel(con[i]), __len + 2));*/
/*    end;*/
run;

proc sort data=rs; by subject rsdtc  visit2;run; 

data pdata.rs1(label='cGVHD Response Assessment');
   retain  __EDC_TreeNodeID  __EDC_EntryDate subject visit2  rsdtc RSSKIN RSEYE RSMOUTH RSPLT RSGASTRO RSLIVER 
          RSLUNG  RSRESP RSRESPNE;
    keep __EDC_TreeNodeID  __EDC_EntryDate subject visit2  rsdtc RSSKIN RSEYE RSMOUTH RSPLT RSGASTRO RSLIVER 
          RSLUNG  RSRESP RSRESPNE;
    set rs;
	if rseval='' and  rsyn='';
run;

data pdata.rs2(label='cGVHD Response Assessment (Continued)');
    retain  __EDC_TreeNodeID  __EDC_EntryDate subject visit2  rsdtc 
RSCONFYN RSCONFIN  RSCONFCM RSCONFSG  RSCONFGV RSCONGO RSCOM;
    keep   __EDC_TreeNodeID  __EDC_EntryDate subject visit2  rsdtc 
RSCONFYN RSCONFIN  RSCONFCM RSCONFSG  RSCONFGV RSCONGO RSCOM;  
    set rs;
	if rseval='' and  rsyn='';
run;

data pdata.rs3(label='PD / Unsched Response Evaluation Visit Prompt');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 rsyn;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 rsyn;
    set rs;
	if rsyn^='';
run;

data pdata.rs4(label='Post Tx Response Follow-Up Visit Prompt');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 rseval rseval;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 rseval rseval;
    set rs;
	if rseval^='';
run;
