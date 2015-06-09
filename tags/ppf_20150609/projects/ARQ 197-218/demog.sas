* Program Name: demog.sas;
* Author: Ken Cao (yong.cao@q2bi.com);
* Initial date: 18/02/2014;

%include '_setup.sas';

%let saeanchor = sae;
%let ovrespanchor = ovresp;
 
proc sql; /*study drug administration chemotherapy*/
    create table _chemo as
    select distinct
        subjid,
        extrt
    from source.ex
    where extrt > '';
    ;
quit;


data dm0; /*demographics*/
    length subjid $25 trttype $50 secop $4 psystx $4 smokhx $4 scrnfl $4  scfre $49 scfothsp $100 icritnum $50 ecritnum $50
            cfaildt 8 icdt 8 scrnfdt 8 inccrit 8 exccrit 8 randdate $30 extrt $12;
    if _n_ = 1 then
        do;
            /* informed consent */
            declare hash inf(dataset:'source.inf');
            rc = inf.defineKey('subjid');
            rc = inf.defineData('icdt');
            rc = inf.defineDone();
            /* randomization result */
            declare hash randrslt(dataset:'source.randrslt');
            rc = randrslt.defineKey('subjid');
            rc = randrslt.defineData('trttype','randdate');
            rc = randrslt.defineDone();
            /* chemotherapy */
             declare hash chemo(dataset:'_chemo');
            rc = chemo.defineKey('subjid');
            rc = chemo.defineData('extrt');
            rc = chemo.defineDone();
            /* eligibility */
            declare hash elig(dataset:'source.elig');
            rc = elig.defineKey('subjid');
            rc = elig.defineData('scrnfl', 'scrnfdt', 'scfre', 'scfothsp', 'inccrit', 'icritnum', 
                 'exccrit', 'ecritnum', 'psystx', 'smokhx');
            rc = elig.defineDone();
            /* cross over */
            declare hash co(dataset:'source.co');
            rc = co.defineKey('subjid');
            rc = co.defineData('secop', 'cfaildt');
            rc = co.defineDone();
 
            call missing(subjid, icdt, trttype, secop, cfaildt, scrnfdt, scrnfl, scfre, scfothsp, inccrit,
                 icritnum, exccrit, ecritnum, psystx, smokhx, extrt, randdate);

        end;
    set source.dm;
    ethni = upcase(ethni);
    if race = 'Other' then race = 'Other: ' || strip(racesp);
    race = upcase(race);
    gender = substr(gender, 1, 1);

    * calculate age: Age is calculated as (Screening Date- Birthday + 1)/365.25.;
    rc = inf.find();
    if n(icdt, brthdt) = 2 then age = int((icdt - brthdt + 1) / 365.25);

    
    * get ARM;
    rc = randrslt.find();
    length arm $40;
    arm = put(trttype, $arm.);

    * chemotherapy;
    rc = chemo.find();
    if extrt > '' then arm = strip(arm) || ' - ' || extrt;

    * eligibility;
    rc = elig.find();
    if scrnfl = 'Yes' then arm = "&escapechar{style[foreground=red]SCREEN FAILURE}";
    length scrnfrsn $200;
    if scfothsp > '' then scrnfrsn = 'OTHER: ' || upcase(scfothsp);
    else scrnfrsn = upcase(scfre);



    * Cross-over?;
    rc = co.find();
    length crsover $10;
    if secop = 'Yes' then crsover = 'Cross-over';

    if crsover > '' then arm = strip(arm) || '(' || strip(crsover) || ')';

    arm = upcase(arm);


    %subjid;
    * title and footnote for all subjects;
    __title1 = strip(subjid) || '(' || strip(subjectinitials) || ')' || ' / ' || strip(gender)|| ' / ' ||
        strip(put(age, best.)) || "&escapechar{super [1]}" || ' / ' || strip(arm) ;
    __footnote1 = "[1]: Age is calculated as (Screening Date- Birthday + 1)/365.25.";
    
    keep subjid ethni race icdt brthdt randdate cfaildt scrnfrsn scrnfdt psystx smokhx __title1 __footnote1 arm;
run;


data ecog; /*baseline ECOG performance*/
    set source.ecog;
    where vttyp = 'Pre-Study';
    %subjid;
    keep subjid ecogstcd;
run;

data kras; /*KARAS mutation type*/
    set source.kras;
    %subjid;
    length krastyp $200;
    if krasmcd = 99 then krastyp = 'Other: ' || strip(krassp);
    else krastyp = krasm;
    keep subjid krastyp;
run;

data baselab1 /* ALT, AST, Total bilirunbin */;
    set source.lblf;
    where vttyp = 'Pre-Study';
    %subjid;
    length alt ast totbil $200 ;
    %labvalue(value=altv, abnfl=alts, outvar=alt);
    %labvalue(value=astv, abnfl=asts, outvar=ast);
    %labvalue(value=totbilv, abnfl=tbils, outvar=totbil);

    keep subjid alt ast totbil;
run;

data baselab2 /* ANC, Hemoglobin, Platelets */;
    set source.lbhm;
    where vttyp = 'Pre-Study';
    %subjid;
    length anc hemog platcnt $200;
    %labvalue(value=abneus, abnfl=abneuv, outvar=anc);
    %labvalue(value=hemogv, abnfl=hemogs, outvar=hemog);
    %labvalue(value=platcntv, abnfl=pltcts, outvar=platcnt);
    keep subjid anc hemog platcnt;
run;

data baselab3 /* serum creatinine */;
    set source.labfchem;
    where vttyp = 'Pre-Study';
    %subjid;
    length creat $200;
    %labvalue(value=creatv, abnfl=creats, outvar=creat);
    keep subjid creat;
run;

data eotarq; /* Disontinuation of ARQ 197 */
    set source.eotarq;
    %subjid;
    keep subjid eotar arqlddt;
run;

data eoterl; /* Disontinuation of Erlotinib */
    set source.eoterl;
    %subjid;
    keep subjid erllddt eoter;
run;

data eotche; /* Distinuation of chemotherapy */
    set source.eotche;
    %subjid;
    keep subjid chelddt eotchr;
run;

data ds0; /* study discontinuation */
    set source.ds;
    %subjid;
    keep subjid dsstdt dsrscd dsrs dsrsosp;
run;

proc sort data = ds0; by subjid dsstdt; run;
data ds;
    set ds0;
        by subjid;
    if first.subjid;
    length exitrsn $200;
    if dsrsosp> '' then exitrsn = 'Other: ' || dsrsosp;
    else exitrsn = dsrs;
    keep subjid dsstdt exitrsn;
run;

data osfu0; /*overall survival follow up*/
    set source.osfu;
    where osfu = 'No';
    %subjid;
    keep subjid osfudt osstat;
run;

proc sort data = osfu0; by subjid osfudt; run;

data osfu;
    set osfu0;
        by subjid;
    if last.subjid;
run;

data death /* Death */;
    set source.dr;
    %subjid;
    length dthcause $200;
    if caudthsp > '' then dthcause = 'Other: ' || strip(caudthsp);
    else dthcause = caudth;
    keep subjid deathdt dthcause caudthcd;
	
run;


/*get number of AE/SAE for each subject*/
data ae0;
	set source.ae;
	%subjid;
	keep subjid aeser;
	if aeser = 'Yes' then 
		do;
			aeser = 'SAE';
			output;
		end;
	aeser = 'AE'; output;
run;

proc freq data = ae0 noprint;
	table subjid*aeser / out = _aenum0(drop=percent); 
run;

proc transpose data = _aenum0 out = _aenum1(drop=_:);
	by subjid;
	id aeser;
	var count; 
run;

data _aenum;
	set _aenum1;
	length aenum $40 saenum $40;
	aenum  = ifc(ae = .,  '0', strip(put(ae, best.)));
	saenum = ifc(sae = ., '0', strip(put(sae, best.)));
	drop ae sae;
run;



* combine all component data;
data demog0;

    merge dm0 ecog kras baselab1 baselab2 baselab3 eotarq eoterl eotche ds osfu death _aenum;
        by subjid;

    length cfaildtc icdtc scrnfdtc arqlddtc erllddtc chelddtc dsstdtc osfudtc deathdtc brthdtc $10;

    %numDate2Char(numdate=cfaildt, chardate=cfaildtc);
    %numDate2Char(numdate=icdt,    chardate=icdtc);
    %numDate2Char(numdate=scrnfdt, chardate=scrnfdtc);
    %numDate2Char(numdate=arqlddt, chardate=arqlddtc);
    %numDate2Char(numdate=erllddt, chardate=erllddtc);
    %numDate2Char(numdate=chelddt, chardate=chelddtc);
    %numDate2Char(numdate=dsstdt,  chardate=dsstdtc);
    %numDate2Char(numdate=osfudt,  chardate=osfudtc);
    %numDate2Char(numdate=deathdt, chardate=deathdtc);
    %numDate2Char(numdate=brthdt,  chardate=brthdtc);

    if randdate > ' ' then randdate = put(input(scan(upcase(randdate), 1, ' '), date11.), yymmdd10.);

    krastyp = upcase(krastyp);
    eotar = upcase(eotar);
    eoter = upcase(eoter);
    eotchr = upcase(eotchr);
    exitrsn = upcase(exitrsn);
    osstat = upcase(osstat);
    dthcause = upcase(dthcause);
	aenum = ifc(aenum='', '0', aenum);
	saenum = ifc(saenum='', '0', saenum);
  

    label
        psystx = 'Prior Systemic Therapies'
        smokhx = 'Smoking History'
        randdate = 'Randomization Date'
        ethni = 'Ethnic'
        race = 'Race'
        scrnfrsn = 'Screening Failure Reason'
        ecogstcd = 'ECOG Performance'
        krastyp = 'KRAS Mutation Type'
        ALT = 'ALT'
        AST = 'AST'
        TOTBIL = 'Total Bilirunbin'
        ANC = 'ANC'
        HEMOG = 'Hemoglobin'
        PLATCNT = 'Platelets'
        CREAT = 'Serum Creatinine'
        EOTAR = 'Reason for ARQ 197 Discontinuation'
        EOTER = 'Reason for Erlotinib Discontinuation'
        EOTCHR = 'Reason for Chemotherapy Discontinuation'
        EXITRSN = 'Reason for Study Discontinuation'
        OSSTAT = 'Last Contact Status'
        DEATHDT = 'Death Date'
        DTHCAUSE = 'Death Cuase'
        CFAILDTC = 'Chemotherapy Failure Date'
        ICDTC = 'Informed Consent Date'
        SCRNFDTC = 'Screening Failure Date'
        ARQLDDTC = 'Last Dose Date of ARQ 197'
        ERLLDDTC = 'Last Dose Date of Erlotinib'
        CHELDDTC = 'Last Dose Date of Chemotherapy'
        DSSTDTC = 'Study Discontinuation Date'
        OSFUDTC = 'Last Contact Date'
        DEATHDTC = 'Death Date'
        brthdtc = 'Brith Date'
		aenum = '# of AE'
		saenum = '# of SAE'
    ;

    drop cfaildt icdt scrnfdt arqlddt erllddt chelddt dsstdt osfudt brthdt;
run;


data pdata.demog1 (label = 'Demographics (No Print)');
    set demog0;
    keep subjid __title1 /*__footnote1*/;
run;


data pdata.demog2 (label = 'Demographics and Key Baseline');
    set demog0;
    /*Part 1: Key demographics*/
    length col $1024;

    /*DemoGraphics*/
    %concat(invars = brthdtc race ethni, ncol = 4, outvar = col); ord = 1; output;
	col = ''; ord = 1; output;

    /*Key Baseline*/
    %concat(invars = psystx smokhx krastyp, ncol = 4, outvar = col); ord = 2; output;
    %concat(invars = alt ast totbil, ncol = 4, outvar = col); ord = 2; output;
    %concat(invars = anc hemog platcnt creat, outvar = col); ord = 2; output;
	col = ''; ord = 2; output;

    /*Key time points*/
	if scrnfdtc > ' ' then 
		do;
    		%concat(invars = icdtc scrnfdtc, ncol = 3, outvar = col); ord = 3; output;
		end;
	else
		do;
			%concat(invars = icdtc randdate, ncol = 3, outvar = col); ord = 3; output;
		end;
	if index(arm, 'EA ARM') > 0 then
		do;
			%concat(invars = arqlddtc erllddtc, ncol = 3, outvar = col); ord = 4; output;
		end;
	else if index(arm, 'CROSS-OVER') > 0 then
		do;
			%concat(invars = chelddtc cfaildtc, ncol=3, outvar = col); ord = 4; output;
			%concat(invars = arqlddtc erllddtc, ncol=3, outvar = col); ord = 4; output;
		end;
	else 
		do;
			%concat(invars = chelddtc, ncol=3, outvar = col); ord = 4; output;
		end;
    %concat(invars = dsstdtc osfudtc deathdtc, outvar = col); ord = 3; output;
	col = ''; ord = 3; output;

    /*Key disposition events*/
    %concat(invars = aenum saenum, ncol=6, outvar = col); ord = 4; output;
	if scrnfdtc > ' ' then 
		do;
    		%concat(invars = scrnfrsn, outvar = col); ord = 4; output;
		end;
    if index(arm, 'EA ARM') > 0 then
		do;
			%concat(invars = eotar, outvar = col); ord = 4; output;
			%concat(invars = eoter, outvar = col); ord = 4; output;
		end;
	else if index(arm, 'CROSS-OVER') > 0 then
		do;
			%concat(invars = eotchr, outvar = col); ord = 4; output;
			%concat(invars = eotar, outvar = col); ord = 4; output;
			%concat(invars = eoter, outvar = col); ord = 4; output;
		end;
	else 
		do;
			%concat(invars = eotchr, outvar = col); ord = 4; output;
		end;

    %concat(invars = exitrsn, outvar = col); ord = 4; output;


	if dthcause = ' ' then dthcause = 'N/A';
	col = "&escapechar{style [fontweight = bold]" || vlabel(dthcause) ||'}: ' || strip(dthcause);

	if caudthcd = 1 then 
		col = "&escapechar{style [url=""#&saeanchor"" foreground=blue textdecoration=underline linkcolor=white]"
			||strip(col)||" (Link to SAE)}"; /*link to sae*/
	else if caudthcd = 2 then  
		col = "&escapechar{style [url=""#&ovrespanchor"" foreground=blue  textdecoration=underline linkcolor=white]"
			||strip(col)||" (Link to Overall Tumor Assessment)}"; /*link to overall response*/

	output;

    keep subjid col ord;
run;
