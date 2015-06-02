/********************************************************************************
 Program Nmae: XM.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

data xm;
 length xmdtc  $20  subject $13 __rfstdtc $10 ;
    
    if _n_ = 1 then do;
       declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set source.xm(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
     %visit2;

	 ****date**;
   label xmdtc = 'Image Date';
    %ndt2cdt(ndt=xmdt, cdt=xmdtc);
    rc = h.find();
    %concatDY(xmdtc);

	 label XMPERF='Were photographic imaging assessments performed at this time point?';
run;

proc sort data=xm; by subject xmdtc  visit2;run; 

data pdata.xm(label='Photographic Imaging of cGVHD');
   retain  __EDC_TreeNodeID  __EDC_EntryDate subject visit2  XMPERF xmdtc;
    keep __EDC_TreeNodeID  __EDC_EntryDate subject visit2 XMPERF xmdtc;
	set xm;
run;

