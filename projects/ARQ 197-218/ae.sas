* Program Name: AE.sas;
* Author: Ken Cao (yong.cao@q2bi.com);
* Initial Date: 18/02/2014;


%include '_setup.sas';

* list of macro variable definition;
%let ftntnum_aesev = 2;


data ae0  (drop = death lifth hosp disperm congano othser)
     sae0 (keep = subjid aenum aeterm aestdtc aeendtc death lifth hosp disperm congano othser aerel);
    set source.ae;
    %subjid;
    * use upper case of adverse term;
    aeterm = upcase(aeterm);
    * numeric date to character date;
    length aestdtc aeendtc $10;
    %numDate2Char(numdate = aestdt, chardate = aestdtc);
    %numDate2Char(numdate = aeendt, chardate = aeendtc);
    * if ongoing AE, then AEENDTC = 'ONGOING';
    if aeongo = 1 then AEENDTC = 'ONGOING';
    keep 
    subjid aenum aeterm aestdtc aeendtc aesevcd aesev aesercd aeser death lifth 
    hosp disperm congano othser aerelcd aerel aerelarq aerelerl aerelpem aereldoc 
    aerelgem aeactcd aeact aeatacd aeata aeatecd aeate aeatpcd aeatp aeatdcd aeatd 
    aeatgcd aeatg aeoatnon aeoatmr aeoathos aeoatoth aeactoth aeoutcd aeout
    ;
    label
        aestdtc = 'Start Date'
        aeendtc = 'End Date'
    ;
    output ae0;
    if aeser = 'Yes' then output sae0;
run;

data sae1;
    set sae0;
    length death_c lifth_c hosp_c disperm_c congano_c othser_c $1;
    array sae{*} death lifth hosp disperm congano othser;
    array sae_c{*} death_c lifth_c hosp_c disperm_c congano_c othser_c;
    do i = 1 to dim(sae);
        sae_c[i] = ifc(sae[i] = 1, 'Y', 'N');
    end;
    drop i death lifth hosp disperm congano othser;
    label 
        death_c   = 'Death'
        lifth_c   = 'Life-Threatening'
        hosp_c    = 'Hospitalization'
        disperm_c = 'Disability'
        congano_c = 'Congenital Anomaly/Birth  Defect'
        othser_c  = 'Important Medical Event'
        ;
run;


data ae1;
    set ae0;
    aesev = put(aesevcd, 1.0);
    %YesNo2YN(aeser);
    %YesNo2YN(aerel);
    %YesNo2YN(aeact);
    length aerel_c $200;

    * study drug;
    length drug1 drug2 drug3 drug4 drug5 $20;
    array drug{*} drug1-drug5 ('ARQ 197', 'Erlotinib', 'Pemetrexed', 'Docetaxel', 'Gemcitabine');

    * causality associated with study drug;
    array aereln{*} aerelarq aerelerl aerelpem aereldoc aerelgem;
    do i = 1 to dim(aereln);
        if aereln[i] = 0 then continue;
        if aerel_c = '' then aerel_c = drug[i];
        else aerel_c = strip(aerel_c) || ', ' || drug[i];
    end;
    if aerel = 'Y' then aerel_c = 'Y: ' || aerel_c;
    else aerel_c = 'N';
    aerel_c = upcase(aerel_c);

    * action taken with study drug;
    length aeacn $200;
    array act{*} aeata aeate aeatp aeatd aeatg;
    do i = 1 to dim(act);
        if aeact = 'N' or act[i] = 'None' or act[i] = '' then continue;
        if aeacn = '' then aeacn = strip(drug[i]) || ': ' || act[i];
        else aeacn = strip(aeacn) || '; ' || strip(drug[i]) || ': ' || act[i];
    end;
    aeacn = upcase(aeacn);
    if aeact = 'N' then aeacn = 'NONE';

    * other action taken;
    length aeacnoth $200;
    length oth1 oth2 oth3 oth4 $100;
    array acnoth{*} aeoatnon aeoatmr aeoathos aeoatoth;
    array acnothc{*] oth1 oth2 oth3 oth4 
            ('None', 'Medication Required', 'Hospitalization or Prolonation of Hospitalization Required', 'Other:');
    do i = 1 to dim(acnoth);
        if acnoth[i] = 0 then continue;
        if aeacnoth = '' then aeacnoth = acnothc[i];
        else aeacnoth = strip(aeacnoth) || '; ' || acnothc[i];
    end;
    aeacnoth = upcase(strip(aeacnoth)) || upcase(aeactoth);

    * outcome;
    aeout = upcase(aeout);
    

    label
        aesev = "CTCAE Grade &escapechar{super [&ftntnum_aesev]}"
        aerel_c = 'Related to Study Drug?'
        aeacn   = 'Action Taken on Study Drug'
        aeacnoth = 'Other Action Taken'
       ;
    keep subjid aenum aeterm aestdtc aeendtc aesev aeser aerel_c aeacn aeacnoth aeout;
run;

proc sort data = ae1; by subjid aestdtc aeendtc aeterm; run;
proc sort data = sae1; by subjid aestdtc aeendtc aeterm; run;

data pdata.ae (label = "Adverse Event");
    retain __label subjid aenum aeterm aestdtc aeendtc aesev aeser aerel_c aeacn aeacnoth aeout;
    keep __label subjid aenum aeterm aestdtc aeendtc aesev aeser aerel_c aeacn aeacnoth aeout;
    set ae1;
	length __label $256;
	__label = "Adverse Event";
	__label = strip(__label)||"&escapechar{newline 3}&escapechar{style [background=#FFFFCC]Yellow: Serious Adverse Event}";
	__label = strip(__label)||"&escapechar{newline 2}&escapechar{style [background=#DBE5F1]Blue: Study drug realted AE}";
run;

data pdata.sae (label = "Serious Adverse Event");
    retain __label subjid aenum aeterm aestdtc aeendtc death_c lifth_c hosp_c disperm_c congano_c othser_c aerel ;
    keep __label subjid aenum aeterm aestdtc aeendtc death_c lifth_c hosp_c disperm_c congano_c othser_c aerel;
    set sae1;
	length __label $256;
	__label = "Serious Adverse Event" ;
	__label = strip(__label)||"&escapechar{newline 3}&escapechar{style [background=#DBE5F1]Blue: Study drug realted AE}";
run;

