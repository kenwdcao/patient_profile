/*********************************************************************
 Program Nmae: exmedi.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data exmedi0;
    set source.exmedi;
    %subject;
    keep EDC_TreeNodeID SUBJECT	CYCLE VISIT MEDILDOS MEDIYN MEDIRSN MEDIOTSP DOSINTED DOSEADM
         DOSERSN DOSEOTSP DOSRACYN DOSINTYN DOSRSTYN INFRESTR EXSEQ	MEAENO01 MEAENO02 MEAENO03	
         DOSEDAT DOSSTTIM DOSENTIM DSAENO01 DSAENO02 DSAENO03 EDC_EntryDate;
run;

data exmedi1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set exmedi0;

	if medildos = 'Checked' then medildos = 'Yes';
	

	** Reason Not Admin.;
	length meno01 meno02 meno03 $20 meaeno $255; 
	label medirsn = "If 'No', specify reason";
	label meaeno = 'AE Record #(s)';
	label mediotsp = "If Other, specify";

	array t(3)meaeno01 meaeno02 meaeno03 ;
    array d(3)meno01 meno02 meno03;
	  do i = 1 to 3;
	    if t(i) ^= . then d(i) = strip(put(t(i), best.));
	  end;
    meaeno = catx(', ', meno01, meno02, meno03);
	drop meaeno0: meno: i;

    length dosdtc dosstmtc dosenmtc $20;
	label   dosdtc = 'Dose Date';
	label dosstmtc = "Infusion Start Time";
	label dosenmtc = "Infusion Stop Time";
	%ndt2cdt(ndt=dosedat, cdt=dosdtc);
    %concatDY(dosdtc);

	%ntime2ctime(ntime=dossttim, ctime=dosstmtc);
    %ntime2ctime(ntime=dosentim, ctime=dosenmtc);
    
	rc = h.find();
	drop rc rfstdtc;
    ** Reason for Administered not the same as Intended;
	length dsno01 dsno02 dsno03 $20 dsaeno $255; 
	label  dosersn = "If Dose Administered is not the same as Dose Intended, provide reason";
	label   dsaeno = "AE Record #(s)";
	label mediotsp = "If Other, specify";
	array k(3)dsaeno01 dsaeno02 dsaeno03;
    array j(3)dsno01 dsno02 dsno03;
	  do m = 1 to 3;
	    if k(m) ^= . then j(m) = strip(put(t(m), best.));
	  end;
    dsaeno = catx(', ', dsno01, dsno02, dsno03);
	drop dsaeno0: dsno: m;
	%visit2;
	visitnum = input(substr(cycle, 7), best.) + input(substr(visit, 5), best.) / 100;
run;

proc sort data=exmedi1; by subject visitnum dosdtc dosstmtc dosenmtc;run;

data pdata.exmedi1(label='Study Drug Administration - MEDI4736');

    retain EDC_TreeNodeID EDC_EntryDate subject exseq visit2 medildos mediyn medirsn meaeno mediotsp dosdtc dosstmtc
           dosenmtc dosinted doseadm;
    keep   EDC_TreeNodeID EDC_EntryDate subject exseq visit2 medildos mediyn medirsn meaeno mediotsp dosdtc dosstmtc
           dosenmtc dosinted doseadm;

    set exmedi1;

    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename          exseq = __exseq;
	label    mediyn = 'Was MEDI4736 administered?';
	label  dosinted = 'Dose Intended (mg)';
	label  doseadm  = 'Dose Administered (mg)';
run;

data pdata.exmedi2(label='Study Drug Administration - MEDI4736 (Continued)');

    retain EDC_TreeNodeID EDC_EntryDate subject exseq visit2 dosersn dsaeno mediotsp dosracyn dosintyn dosrstyn infrestr;
    keep   EDC_TreeNodeID EDC_EntryDate subject exseq visit2 dosersn dsaeno mediotsp dosracyn dosintyn dosrstyn infrestr;
    set exmedi1;

    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename          exseq = __exseq;

	label  dosracyn = 'Did subject have infusion related reaction?';
	label  dosintyn = 'Was infusion interrupted?';
	label  dosrstyn = 'If infusion was interrupted was MEDI4736 restarted?';
	label  infrestr = "If 'Yes', what happened when MEDI4736 was restarted?";
run;



