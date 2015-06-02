/*********************************************************************
 Program Nmae: prisg.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/
%include '_setup.sas';

data prisg0; 
    set source.prisg_coded;
	%subject;
	keep EDC_TreeNodeID SUBJECT VISIT PRISGDY PRISGMO PRISGYR SGTYP SGDESC PSGSEQ MedDRA_v PRISGBODSYS 
         PRISGLLT PRISGSOC PRISGHLGT PRISGHLT PRISGDECOD PRISGBDSYCD PRISGLLTCD PRISGSOCCD PRISGHLGTCD PRISGPTCD 
         PRISGHLTCD COMMENTS EDC_EntryDate;
run;
 
data prisg1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set prisg0;
  
    length prisgdtc $20;
	label prisgdtc = 'Surgery / Procedure Date';
    %concatdate(year=prisgyr, month=prisgmo, day=prisgdy, outdate=prisgdtc);
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(prisgdtc);
    drop prisgyr prisgmo prisgdy;


    length _sgdesc $512;
    label _sgdesc = "System Organ Class/&splitchar.Preferred Term/&splitchar.Surgery / Procedure Description / Location";
    _sgdesc = strip(prisgbodsys) || "/&escapeChar.n" || strip(prisgdecod) || "/&escapeChar.n" || strip(sgdesc); 
run;


proc sort data = prisg1; by subject prisgdtc sgdesc; run; 


data pdata.prisg(label='Prior Cancer Surgeries and Procedures');
    retain EDC_TreeNodeID EDC_EntryDate subject psgseq prisgdtc sgtyp _sgdesc sgdesc prisgdecod prisgbodsys
           prisgsoc prisgllt prisghlgt prisghlt; 
    keep   EDC_TreeNodeID EDC_EntryDate subject psgseq prisgdtc sgtyp _sgdesc sgdesc prisgdecod prisgbodsys
           prisgsoc prisgllt prisghlgt prisghlt; 
         
    set prisg1;
    
    rename    EDC_TreeNodeID = __EDC_TreeNodeID;
    rename     EDC_EntryDate = __EDC_EntryDate;
    rename          psgseq   = __psgseq;
    rename          prisgllt = __prisgllt;
    rename          prisghlt = __prisghlt;
    rename         prisghlgt = __prisghlgt;
    rename          prisgsoc = __prisgsoc;
    rename            sgdesc = __sgdesc;
    rename        prisgdecod = __prisgdecod;
    rename       prisgbodsys = __prisgbodsys;

run;
