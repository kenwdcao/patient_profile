/********************************************************************************
 Program Nmae: XD.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

data xd;
 length xddtc  $20  subject $13 __rfstdtc $10   orres $50  ;
    
    if _n_ = 1 then do;
       declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set source.xd(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
     %visit2;

	 ****date**;
   label xddtc = 'Assessment Date';
    %ndt2cdt(ndt=xddt, cdt=xddtc);
    rc = h.find();
    %concatDY(xddtc);

	 label   orres='Result';

**orres nd**;
	array aa xdnr  xdna motionnp ;
	do over aa;
	 if aa='Checked' then aa='Yes'; 
	 end;

	 **modify orresu**;
/*     if xdorres^='' and xdorresu^='' then orres=cat(strip(xdorres),' ',strip(xdorresu));*/
	     orres=coalescec(strip(xdorres), strip(XDDESC),strip(xdorres1),strip(motion));

run;

proc sort data=xd; by subject  xddtc  visit2 xdscat xdtest ;run; 

data pdata.xd1 (label='cGVHD Assessment - Clinician');
   retain  __EDC_TreeNodeID  __EDC_EntryDate subject visit2  xddtc xdscat xdtest orres xdorresu xdna  motionnp;
    keep __EDC_TreeNodeID  __EDC_EntryDate subject visit2 xddtc  xdscat xdtest orres xdorresu xdna  motionnp;
	set xd;
       if EDC_FormLabel='cGVHD Assessment – Clinician';
run;

data pdata.xd2 (label='cGVHD Assessment - Patient Self Report');
   retain  __EDC_TreeNodeID  __EDC_EntryDate subject visit2  xddtc xdtest orres xdnr ;
    keep __EDC_TreeNodeID  __EDC_EntryDate subject visit2 xddtc xdtest orres xdnr ;
	set xd;
       if EDC_FormLabel='cGVHD Assessment – Patient Self Report';
	   	   label xdtest='Symptom Severity in last 7 days';
run;

