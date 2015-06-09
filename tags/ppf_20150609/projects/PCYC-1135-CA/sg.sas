/*********************************************************************
 Program Nmae: sg.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/
%include '_setup.sas';

data sg0; 
    set source.sg;
	%subject;
	keep EDC_TreeNodeID SUBJECT	SGTYP SGDESC SGANTIYN SGSEQ SGDAT /*MedDRA_v SGBODSYS SGLLT SGSOC SGHLGT SGHLT
          SGDECOD SGBDSYCD SGLLTCD SGSOCCD SGHLGTCD SGPTCD SGHLTCD COMMENTS*/ EDC_EntryDate;
run;
 
data sg1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set sg0;
  
    length sgdtc $20;
	label sgdtc = 'Surgery / Procedure Date';
    %ndt2cdt(ndt=sgdat, cdt=sgdtc);
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(sgdtc);
    drop sgdat;
    label sgantiyn = 'Was this considered an anti-cancer therapy?';
/*    length _sgdesc $512;*/
/*    label _sgdesc = "System Organ Class/&splitchar.Preferred Term/&splitchar.Surgery / Procedure Description / Location";*/
/*    _sgdesc = strip(sgbodsys) || "/&escapeChar.n" || strip(sgdecod) || "/&escapeChar.n" || strip(sgdesc); */
run;


proc sort data = sg1; by subject sgdtc sgdesc; run; 


data pdata.sg(label='Surgeries and Procedures');
    retain EDC_TreeNodeID EDC_EntryDate subject sgseq sgdtc sgtyp /*_sgdesc*/ sgdesc sgantiyn /*sgdecod sgbodsys
           sgsoc sgllt sghlgt sghlt*/; 
    keep   EDC_TreeNodeID EDC_EntryDate subject sgseq sgdtc sgtyp /*_sgdesc*/ sgdesc sgantiyn /*sgdecod sgbodsys
           sgsoc sgllt sghlgt sghlt*/; 
         
    set sg1;
    
    rename    EDC_TreeNodeID = __EDC_TreeNodeID;
    rename     EDC_EntryDate = __EDC_EntryDate;
    rename             sgseq = __sgseq;
/*    rename          sgllt = __sgllt;*/
/*    rename          sghlt = __sghlt;*/
/*    rename         sghlgt = __sghlgt;*/
/*    rename          sgsoc = __sgsoc;*/
/*    rename            sgdesc = __sgdesc;*/
/*    rename        sgdecod = __sgdecod;*/
/*    rename       sgbodsys = __sgbodsys;*/

run;
