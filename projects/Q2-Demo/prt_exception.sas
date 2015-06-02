
/** !-- adjustment for proc report -- **/

%macro prt_exception;
/*
%if %upcase(&dset) = DM %then %do;
    column birthdtc cbp ("&escapechar.S={just=c}If No, Specify Reason" cbpn01 cbpn02 cbpn04 cbpn03 cbpn05 cbpno) ethnic race country __:;
    define cbpn:/ style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;
%else
*/ %if %upcase(&dset) = AE1 %then %do;
    define aeout / 'Outcome';
%end;
%else %if %upcase(&dset) = AE2 %then %do;
    column aenum aeterm 
        ("&escapechar.S={just=c}Action Taken with Study Drug (ibrutinib)" aeacn03 aeacn04 aeacn05 aeacn01)
        _blank_
        ("&escapechar.S={just=c}Other Action Taken" aeacno02 aeacno03 aeacno04 aeacno01 aeacnoth)
        __:
    ;
    
    define aeacn: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define _blank_ / ' ' style(column) = [width=0.05in] computed;
    define aeacno: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define aeacnoth / 'Other(Specify)' style(column)=[width=1.2in];
%end;
%else %if %upcase(&dset) = AM1 %then %do;
    column amterm amdtc ambpyn ambpynsp 
        ("&escapechar.S={just=c}Staging" amstgt amstgn amstgm amstgnr amstgos)
        _blank_
        ("&escapechar.S={just=c}Treatment" amtrt1 amtrtd2 amtrtd3 amtrtd4 amtrtd5 amtrtd6) 
          __:
    ;
    /*
    define amterm / style(column)=[width=0.5in];
    define amdtc / style(column)=[width=0.4in];
    define ambpyn / style(column)=[width=0.5in];
    define ambpynsp / style(column)=[width=0.5in];
    */
    define amstg: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define _blank_ / ' ' computed style(column)=[width=0.1in];
    define amtrt: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;
%else %if %upcase(&dset) = AM2 %then %do;
    column amterm amout
        /*
        ("&escapechar.S={just=c}If treatment was administered with curative intent" amcuri amrel amrelsp amcyto)
        _blank_
        */
    amcuri amrel amrelsp amcyto
    ("&escapechar.S={just=c}Patient’s cancer risks" amrisk1 amriskd2 amriskd3 amriskd4 amriskd5 amriskd6 amriskd7) mhnum __:;
    define amterm / style(column)=[width=0.9in];
    define amout / style(column)=[width=0.9in];
    /*
    define amcuri / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define amrel / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define amrelsp / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define amcyto / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define _blank_ / ' ' computed style(column)=[width=0.05in];
    */
    define amrisk: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;
%else %if %upcase(&dset) = SS %then %do;
    define visit / 'Visit';
%end;
%else %if %upcase(&dset) = BP1 %then %do;
    column visit xbdtc xblbnd xblbcd xbovcel xboccur xblinf  
         ("&escapechar.S={just=c}Method of Assessment" xbmeth1 xbmeth2 xbmeth3 xbmeth5 xbmeth6)
         __:
    ;
    define xbmeth: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define xbmeth6 / style(column) = [width=2.0in];
%end;
%else %if %upcase(&dset) = BP2 %then %do;
    column visit xbdtc xblbnd xblbcd 
         ("&escapechar.S={just=c}Were additional samples collected and sent to central lab" xblabyn1 xblabyn2 xblabyn3 xblabrea) 
         __:
    ;
    define xblab: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;
%else %if %upcase(&dset) = TL1 %then %do;
    column visit tlnum tltype tlsite tlsitesp tldtc tlnd tlstus 
        ("&escapechar.S={just=c}Lesion Measurement" tlmeas1_ tlmeas2_ tlpdiam_ tlmeth) tlpetyn 
        __:;
    define tlsite / style(column) = [width=0.55in];
    define tlsitesp / style(column) = [width=0.9in];
    define tlmeas1_ / 'Long axis#(cm)' style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] style(column)=[width=0.40in];
    define tlmeas2_ / 'Short axis#(cm)' style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] style(column)=[width=0.45in];
    define tlpdiam_ / /*"Product of Diam.#(cm&escapechar{super} 2)"*/ style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define tlpdiam_ / style(column)=[width=0.65in];
    define tlmeth / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')]  style(column) = [width=0.8in];;
%end;
%else %if %upcase(&dset) = ES %then %do;
    column visit qsdtc qsstat qsorres __:;
%end;
%else %if %upcase(&dset) = LD %then %do;
    define egspid / 'Measurement #';
%end;
%else %if "%upcase(&dset)" = "NE" %then %do;
     column  visit nedtc nenum nesitesp nestus 
        ("&escapechar.S={just=c}Lesion Measurement" nemeas1 nemeas2 nepdiam nemeth)
        nepetyn necom __:
     ;
    define nemeas1 / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] ;
    define nemeas2 / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] ;
    define nepdiam / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] ;
    define nemeth /  style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] ;
%end;
%else %if %upcase(&dset) = NN %then %do;
     column  visit nndtc nnnum nnsite nnsitesp nnstus 
         ("&escapechar.S={just=c}Lesion Measurement" nnmeas1 nnmeas2 nnpdiam nnmeth)
         nnpetyn nncom __:
     ;
    define nnmeas1 / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] ;
    define nnmeas2 / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] ;
    define nnpdiam / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] ;
    define nnmeth /  style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] ;
%end;
%else %if %upcase(&dset) = MD1 %then %do;    
    column mddtc mdstype 
        ("&escapechar.S={just=c}Evidence for progressive disease" mdpdl mdpdnl mdpdnlbp mdpdoth mdpdoths mdpdnone)
        __:;

    define mdpd: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;
%else %if %upcase(&dset) = MD2 %then %do;    
    column mddtc mdstype 
        ("&escapechar.S={just=c}Evidence for need for treatment" mdtt mdtbd mdtsym mdtrt mdtrgf mdtoth)
        __:;
    define mdt: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;
%else %if %upcase(&dset) = BS %then %do;
    column visit bsdtc bsnd bsyn 
        ("&escapechar.S={just=c}If Yes, Specify Symptoms:" bswl bswlsig bsfev bssweat bsoccur) __:;
    ;
    define bswl / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define bswlsig / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define bsfev / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define bssweat / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define bsoccur / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;
%else %if %upcase(&dset) = CT1 %then %do;
    column visit ctdtc 
        ("&escapechar.S={just=c}CT with contrast" ctres1 ctres1n ctres1c ctres1a ctres1p  ctres1s) 
        _blank_
        ("&escapechar.S={just=c}CT without contrast" ctres2 ctres2n ctres2c  ctres2s)
        __:;
    define ctres1: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define ctres2: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define _blank_ / ' ' style(column) = [width=0.1in] computed;
%end;
%else %if %upcase(&dset) = CT2 %then %do;
    column visit ctdtc 
        ("&escapechar.S={just=c}MRI" ctres3 ctres3a ctres3p  ctres3s)
        _blank_
        ("&escapechar.S={just=c}If MRI, Specify Reason" ctmri1 ctmri2  ctmrioth)
        ctespl cteliv __:;
    define ctres3: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define ctmri: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define _blank_ / ' ' style(column) = [width=0.1in] computed;
%end;
%else %if %upcase(&dset) = RD %then %do;
    column rdstdtc rdendtc 
        ("&escapechar.S={just=c}Involved Field" rdsite09 rdsite03 rdsite01 rdsite04 rdsite10 rdsite02 rdsite05 rdsiteio)
        _blank_
        ("&escapechar.S={just=c}Regional Field" rdsite06 rdsite07 rdsite08 rdsite12 rdsiteo) 
        __:;
    define rdsite: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define _blank_ / ' ' style(column) = [width=0.1in] computed;
%end;
%else %if %upcase(&dset) = RS1 %then %do;
   define rstrb / 'Overall Tumor Response is based on...' ;
%end;
%else %if %upcase(&dset) = RS2 %then %do;
    column visit rspdtl_
         ("&escapechar.S={just=c}Increase in size of other nodal lesion" rspdnts rspdexnl)
            rspdexns rspdlns rspdnexs rspdcps rspdoths
        __:;
    define rspdnts / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define rspdexnl / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    /*
    define visit / style(column) = [width=1.0in];
    define rsp: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define rspdtl_ / style(column) = [width=0.7in];
    define rspdnts / style(column) = [width=0.7in];
    define rspdexns / style(column) = [width=0.8in];
    define rspdnexs/  style(column) = [width=1.5in];
    define rspdlns / style(column) = [width=1.5in];
    define rspdoths/ style(column) = [width=1.2in];
    */
%end;
/*
%else %if %upcase(&dset) = PE1 %then %do;
    define GA / style(column) = [width=20%];
    define SKIN / style(column) = [width=20%];
    define HEENT / style(column) = [width=20%];
%end;
%else %if %upcase(&dset) = PE2 %then %do;
    define RESP / style(column) = [width=15%];
    define CARD / style(column) = [width=15%];
    define ABDOMEN / style(column) = [width=15%];
    define EXTREM / style(column) = [width=15%];
%end;
%else %if %upcase(&dset) = PE3 %then %do;
    define MUSC / style(column) = [width=15%];
    define LYMPHATI / style(column) = [width=15%];
    define NERVOUS / style(column) = [width=15%];
    define OTHER / style(column) = [width=15%];
%end;
*/
%mend prt_exception;


