/*********************************************************************
 Program Nmae: ae.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data ae0;
    set source.ae_coded;
    %subject;
    keep EDC_TreeNodeID SUBJECT AETERM AESER AESTDY AESTMO AEOUT AESTYR CHANGE AEENDY AEENMO AEENYR AETOXGR BTKREL MEDIREL 
         BTKACT1 BTKACT2 BTKACT3 BTKACT4 BTKACT5 MEDIACT1 MEDIACT2 MEDIACT3 MEDIACT4 MEDIACT5 AEACNOT1 AEACNOT2 AEACNOT3 AEACNOT4 
         AEACNOT5 AEAOTHSP AEDLT AEIMMN AESEQ MedDRA_v AELLTCD AELLT AESOCCD AESOC AEHLGTCD AEHLGT AEHLTCD AEHLT AEPTCD AEDECOD 
         COMMENTS AEBODSYS AEBDSYCD EDC_EntryDate;
run;

data ae1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set ae0;

    length aestdtc $20 aeendtc $20;
    %concatdate(year=aestyr, month=aestmo, day=aestdy, outdate=aestdtc);
    %concatdate(year=aeenyr, month=aeenmo, day=aeendy, outdate=aeendtc);
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(aestdtc);
    %concatDY(aeendtc);
    drop aestyr aestmo aestdy aeenyr aeenmo aeendy;

    length _aeterm $512;
    _aeterm = strip(aebodsys)||"/&escapechar.n"||strip(aedecod)||"/&escapechar.n"||strip(aeterm);

    length bact1-bact5 mact1-mact5 acnot1-acnot5 _btkact _mediact _aeacnot $255;
    label _btkact = 'Ibrutinib@:Action Taken with Study Treatment';
    label _mediact = 'MEDI4736@:Action Taken with Study Treatment';
    label _aeacnot = 'Other Action Taken';

    ** Action Taken with Ibrutinib;
    if btkact1 = 'Checked' then bact1 = 'Not Applicable';
    if btkact2 = 'Checked' then bact2 = 'Dose Not Changed';
    if btkact3 = 'Checked' then bact3 = 'Dose Reduced';
    if btkact4 = 'Checked' then bact4 = 'Drug Interrupted';
    if btkact5 = 'Checked' then bact5 = 'Drug permanently withdrawn';
    _btkact = catx('; ', of bact1-bact5);

    ** Action Taken with MEDI4736;
    if mediact1 = 'Checked' then mact1 = 'Not Applicable';
    if mediact2 = 'Checked' then mact2 = 'Dose Not Changed';
    if mediact3 = 'Checked' then mact3 = 'Dose Reduced';
    if mediact4 = 'Checked' then mact4 = 'Drug Interrupted';
    if mediact5 = 'Checked' then mact5 = 'Drug permanently withdrawn';
    _mediact = catx('; ', of mact1-mact5);
   
    ** Other Action Taken;
    if aeacnot1 = 'Checked' then acnot1 = 'Not Applicable';
    if aeacnot2 = 'Checked' then acnot2 = 'Medication';
    if aeacnot3 = 'Checked' then acnot3 = 'Non-drug therapy';
    if aeacnot4 = 'Checked' then acnot4 = 'Hospitalization / prolongation of hospitalization';
    if aeacnot5 = 'Checked' and aeaothsp ^= '' then acnot5 = 'Other: ' || strip(aeaothsp);
      else if aeacnot5 = 'Checked' and aeaothsp = '' then acnot5 = 'Other';
    _aeacnot = catx('; ', of acnot1-acnot5);

    drop btkact: mediact: aeacnot: bact: mact: acnot:;  
run;

proc sort data=ae1; by subject aestdtc aeendtc aeterm ;run;

data pdata.ae1(label='Adverse Event');

    retain EDC_TreeNodeID EDC_EntryDate subject aeseq _aeterm aeterm aedecod aebodsys aeser aestdtc aeout change aeendtc aetoxgr
           btkrel medirel aellt aehlt aehlgt aesoc;
    keep   EDC_TreeNodeID EDC_EntryDate subject aeseq _aeterm aeterm aedecod aebodsys aeser aestdtc aeout change aeendtc aetoxgr
           btkrel medirel aellt aehlt aehlgt aesoc;

    set ae1;

    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename          aeseq = __aeseq;
    rename          aellt = __aellt;
    rename          aehlt = __aehlt;
    rename         aehlgt = __aehlgt;
    rename          aesoc = __aesoc;
    rename         aeterm = __aeterm;
    rename        aedecod = __aedecod;
    rename       aebodsys = __aebodsys;

    label _aeterm = "System Organ Class/&splitchar.Preferred Term/&splitchar.Verbatim Term";
    label   aeser = 'SAE?';
    label aetoxgr = 'Toxicity/Severity Grade';
    label aestdtc = 'Start Date';
    label   aeout = 'Outcome';
    label  change = "If Resolved, was this due to change in seriousness/severity?";
    label aeendtc = 'End Date';
    label  btkrel = 'Ibrutinib@:Relationship to'; 
    label medirel = 'MEDI4736@:Relationship to';

run;


data pdata.ae2(label='Adverse Event (Continued)');
    retain EDC_TreeNodeID EDC_EntryDate subject aeseq _aeterm aeterm aedecod aebodsys _btkact _mediact _aeacnot aedlt aeimmn; 
    keep EDC_TreeNodeID EDC_EntryDate subject aeseq _aeterm aeterm aedecod aebodsys _btkact _mediact _aeacnot aedlt aeimmn; 
    set ae1;
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename          aeseq = __aeseq;
    rename         aeterm = __aeterm;
    rename        aedecod = __aedecod;
    rename       aebodsys = __aebodsys;

    label _aeterm = "System Organ Class/&splitchar.Preferred Term/&splitchar.Verbatim Term";
run;
