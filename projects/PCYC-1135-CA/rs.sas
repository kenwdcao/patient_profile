/*********************************************************************
 Program Nmae: RS.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/29
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data rs1_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.rs;
	%subject;
	%visit2;

	** Response Assessment Date;
	length rsdtc $20;
	label rsdtc = 'Response Assessment Date';
	if RSASDAT^=. then rsdtc=put(RSASDAT,yymmdd10.);else rsdtc="";
	rc = h.find();
	%concatDY(rsdtc);
	drop RSASDAT rc;

	** any confounding factors;
	length _RSINF _RSCNMED _RSSGPRC _RSTUMOR _RSOTH $200;
	%let rslab = @:If 'Yes', mark all that apply;
	label  RSOVRSP = "Provide Investigator's Response Assessment by protocol criteria"
	      RSRSNESP = "If 'Not Evaluable', please specify reason"
		  RSCFCTYN = "Are there any confounding factors that may impact ability to accurately assess this response?"
            _RSINF = "Infection (specify)&rslab"
	      _RSCNMED = "Concomitant Medication (specify)&rslab"
          _RSSGPRC = "Surgery / Procedure (specify)&rslab"
          _RSTUMOR = "Tumor flare (specify)&rslab"
            _RSOTH = "Other (specify)&rslab"
		  ;
	if RSINF ne '' and RSINFSP ne '' then _RSINF = 'Yes: ' || strip(RSINFSP); else
		if RSINF ne '' and RSINFSP eq '' then _RSINF = 'Yes'; 
	if RSCNMED ne '' and RSCMSP ne '' then _RSCNMED = 'Yes: ' || strip(RSCMSP); else
		if RSCNMED ne '' and RSCMSP eq '' then _RSCNMED = 'Yes'; 
	if RSSGPRC ne '' and RSPRCSP ne '' then _RSSGPRC = 'Yes: ' || strip(RSPRCSP); else
		if RSSGPRC ne '' and RSPRCSP eq '' then _RSSGPRC = 'Yes'; 
	if RSTUMOR ne '' and RSTUMRSP ne '' then _RSTUMOR = 'Yes: ' || strip(RSTUMRSP); else
		if RSTUMOR ne '' and RSTUMRSP eq '' then _RSTUMOR = 'Yes'; 
	if RSOTH ne '' and RSOTHSP ne '' then _RSOTH = 'Yes: ' || strip(RSOTHSP); else
		if RSOTH ne '' and RSOTHSP eq '' then _RSOTH = 'Yes'; 
run;

proc sort data=rs1_1 out=preout; by subject rsdtc VISIT2; run;

data pdata.rs1(label='Overall Disease Assessment');
	retain __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 RSDTC RSTGRSP RSNTGRSP RSNEWYN RSOVRSP RSRSNESP;
    keep __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 RSDTC RSTGRSP RSNTGRSP RSNEWYN RSOVRSP RSRSNESP;
    set preout;
/*	label TBXND='Check if Not Done';*/
run;

data pdata.rs2(label='Overall Disease Assessment (Continued)');
	retain __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 RSDTC RSCFCTYN _RSINF _RSCNMED _RSSGPRC _RSTUMOR _RSOTH;
    keep __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 RSDTC RSCFCTYN _RSINF _RSCNMED _RSSGPRC _RSTUMOR _RSOTH;
		;
    set preout;
/*	label TBXND='Check if Not Done';*/
run;

