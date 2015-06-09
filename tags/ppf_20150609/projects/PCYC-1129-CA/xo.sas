/********************************************************************************
 Program Nmae: XO.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

data xo;
 length xodtc  $20  subject $13 __rfstdtc $10 xoorres $200;
    
    if _n_ = 1 then do;
       declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set source.xo(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
     %visit2;

	 ****date**;
   label xodtc = 'Assessment Date';
    %ndt2cdt(ndt=xodt, cdt=xodtc);
    rc = h.find();
    %concatDY(xodtc);

	****orres**;
	 label xoorres='Result';

    if index(XOSAT,'%')=0 and xosat^=''  then xoorres=strip(XOSAT)||strip(XOSATU);
       else xoorres= strip(XOSAT);
    if XOFEV1^='' then xoorres=strip(XOFEV1)||strip(XOFEV1u);
run;

proc sort data=xo; by subject xodtc  visit2;run; 

data pdata.xo(label='Oxygen Saturation/PFT');
   retain  __EDC_TreeNodeID  __EDC_EntryDate subject visit2  xometh xodtc xoorres;
    keep __EDC_TreeNodeID  __EDC_EntryDate subject visit2 xometh  xodtc xoorres;
	set xo;
run;

