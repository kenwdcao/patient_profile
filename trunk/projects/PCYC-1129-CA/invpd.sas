/********************************************************************************
 Program Nmae: INVPD.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

data invpd_;
        set source.INVPD;
		array aa  PDEYEDT  PDLUNDT  PDPLDT  PDSKDT  PDMODT  PDGASTDT  PDLIV2DT  PDLIV1DT;
		array bb  $20 PDEYED  PDLUND  PDPLD  PDSKD  PDMOD  PDGASTD  PDLIV2D  PDLIV1D;
		do over aa;
		if aa^=. then bb = put(aa, YYMMDD10.);
		end;
		col1='';
run;

 proc transpose data=invpd_ out=invpd1(rename=(_name_=testcd  _label_=testl));
         by EDC_TreeNodeID EDC_EntryDate subject VISIT UNSSEQ ;
         var PDLIV1  PDGAST  PDMO  PDLIV2  PDSK  PDEYE  PDPL  PDLUN;
run;

proc transpose data=invpd_ out=invpd2(rename=(_name_=dtc  ));
           by EDC_TreeNodeID EDC_EntryDate subject VISIT UNSSEQ col1;
         var PDEYED  PDLUND  PDPLD  PDSKD  PDMOD  PDGASTD  PDLIV2D  PDLIV1D;
run;

data invpd1_;
      set invpd1;
	  key=_n_;
run;

data invpd2_;
      set invpd2;
	  key=_n_;
run;

proc sort data= invpd1_; by EDC_TreeNodeID EDC_EntryDate subject  key; run;

proc sort data= invpd2_; by EDC_TreeNodeID EDC_EntryDate subject key; run;

proc format;
value $l
'Skin'='Skin (percent of body surface) e - s >= 25?'
'Eye'='Eye s - e >= 5 mm?'
'Mouth'='Mouth (15-point Schubert scale) e - s >= 3?'
'Platelet'='Platelet count s - e >= 50,000/uL and e < LLN?'
'Gastrointestinal'='Gastrointestinal (and other 0 - 3 scales) e - s >= 1?'
'Liver >=3'='Liver (ALT, alkaline phosphatase and bilirubin), eosinophil count, if s >= 3x ULN, is e - s >= 3 x ULN?'
'Liver <=3'='Liver (ALT, alkaline phosphatase and bilirubin), eosinophil count, if s < 3x ULN, is e - s >= 2 x ULN?'
'Lungs'='Lungs (12-point Lung Function Scale) e - s >=3?'
;
run;


data invpd3;
length label $100 test $300;
         merge invpd1_  invpd2_;
         by EDC_TreeNodeID EDC_EntryDate subject key;
		 label=substr(testl,length('Criteria Used')+2);
		 test=put(label,$l.);
		label test ='Indicate criteria used to determine PD';     
run;

data INVPD;
 length col  $20  subject $13 __rfstdtc $10 ;
    
    if _n_ = 1 then do;
       declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set invpd3 (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
     %visit2;

	 ****date**;
   label col = 'Assessment Date';
/*    %ndt2cdt(ndt=col1, cdt=col);*/
    rc = h.find();
    %concatDY(col);	
	IF COL^='';
run;

proc sort data=INVPD; by subject col  visit2;run; 

data pdata.INVPD(label='Disease Progression (PD) by Investigator');
   retain  __EDC_TreeNodeID  __EDC_EntryDate subject visit2 test col ;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 test col ;
	set INVPD;
run;

