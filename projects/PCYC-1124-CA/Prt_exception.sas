/********************************************************************************
 Program Nmae: prt_exception.sas
  @Author: 
  @Initial Date: 2015/02/28
 
 Interface to let user alter proc report statements.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/

%macro prt_exception();
define _numeric_ / format=d2b10.;
%if %upcase(&dset) = DM %then %do;
    column birthdtc sex cbp ("&escapechar.S={just=c}If ""No"", Specify Reason" cbpn02 cbpn04 cbpn01 cbpno)  ethnic race __:;
    define cbpn: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;

%else %if %upcase(&dset) = CT %then %do;
    column visit2 ctdtc ("&escapechar.S={just=c} CT/MRI Assessments" ctres1 ctres2 ctres3)   _blank_ 
        ("&escapechar.S={just=c} If MRI, Specify Reason" ctmri1 ctmri2 ctmrioth) ctespl cteliv __:;
    define ctres1 / "CT with Contrast" style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define ctres2 / "CT without Contrast" style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define ctres3 / "MRI" style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define ctmri1 /  "CT contrast contraindicated" style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define ctmri2 /  "Lesions not well visualized by CT" style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define ctmrioth /  "Other Specify" style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define _blank_ / ' ' style(column)=[width=0.1in] computed;
%end;

%else %if %upcase(&dset) = TL1 %then %do;
    column visit2 tldtc tlnum tltype tlsite tlsitesp tlnd tlstus 
        ("&escapechar.S={just=c}Lesion Measurement" tlmeas1_ tlmeas2_ tlpdiam_ tlmeth tlmethsp) tlpetyn __:;
    define tlmeas1_ / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define tlmeas2_ / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define tlpdiam_ / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define tlmeth / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define tlmethsp / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];;
%end;

%else %if %upcase(&dset) = NN1 %then %do;
    column visit2 nndtc nnnum nnsite nnsitesp nnnd nnstus 
        ("&escapechar.S={just=c}Lesion Measurement" nnmeas1_ nnmeas2_ nnpdiam_ nnmeth nnmethsp) nnpetyn __:;
    define nnmeas1_ / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define nnmeas2_ / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define nnpdiam_ / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define nnmeth / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define nnmethsp / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];;
%end;

%else %if %upcase(&dset) = NE1 %then %do;
    column visit2 nedtc nenum nesitesp nend nestus 
        ("&escapechar.S={just=c}Lesion Measurement" nemeas1_ nemeas2_ nepdiam_ nemeth nemethsp) nepetyn __:;
    define nemeas1_ / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define nemeas2_ / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define nepdiam_ / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define nemeth / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define nemethsp / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];;
%end;

%else %if %upcase(&dset) = ML1 %then %do;
    column manum mldiag mldtc mlfindsp ("&escapechar.S={just=c}STAGING" mlstaget mlstagen mlstagem mlstageo) __:;
    define mlstage: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;

%else %if %upcase(&dset) = LBHEML1 %then %do;
    column visit2 lbdtc lbtmc lbcode lbacelyn lbacelsp wbc rbc hgb hct plat __:;
    define lbacelsp /style(column)=[width=1.8in];
%end;

%else %if %upcase(&dset) = CMRX2 %then %do;
    column rxrgnum rxrgnumn _rxtryn rxtrdtc rxresp rxprdtc _pddetrm 
           ("&escapechar.S={just=c}Evidence for progressive disease" pdsinc pdnles_ pdoth_ )
           __:;
    define pdsinc / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define pdnles_ / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] style(column)=[width=1.2in];
    define pdoth_ / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')] style(column)=[width=1.3in];;
%end;

%else %if %upcase(&dset) = CM2 %then %do;
    column __cmcat cmnum __cmseq  cmtrt cmindc bspig growth 
    ("&escapechar.S={just=c}Primary reason for treatment" cmreas01 cmreas02_ cmreas03_)  __:;
    define cmreas01 / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define cmreas02_ / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define cmreas03_ / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];

%end;
%else %if %upcase(&dset) = BP1 %then %do;
    column visit xbdtc ("&escapechar.S={just=c}Sample(s) Obtained" xbperfa xbperfb)
           xblbcd cellular lymcyinv xblinf 
           ("&escapechar.S={just=c}Method of Assessment" xbmeth1 xbmeth2 xbmeth3 xbmeth5 xbmeth6)   __:
    ;

    define xbperf: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
    define xbmeth: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];

%end;
%else %if %upcase(&dset) = BP2 %then %do;
    column visit xbdtc 
           ("&escapechar.S={just=c}Were additional samples collected and sent to central lab" xblabyn1 xblabyn2 xblabyn3)
           xblaban xblabrea
            __:
    ;
    define xblabyn: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];

%end;
%else %if %upcase(&dset) = EG2 %then %do;
    column visit2 egdtc egoccur1 ("&escapechar.S={just=c}If Yes, specify the type of rhythm abnormality" egtype1  egtype2 egtype3 egtypeo)
           egoccur2 egoccur3 egoccuro __:;
    define egtype: /  style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;
%else %if %upcase(&dset) = AE1 %then %do;
    column aenum _aeterm aeser aedlt aestdtc aeout aeendtc aetoxgr 
           ("&escapechar.S={just=c}Relationship to" aereli aerell aerele)
            __:;
    define aerel: /  style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;
%else %if %upcase(&dset) = AE2 %then %do;
    column aenum _aeterm 
           ("&escapechar.S={just=c}Action Taken" _aeacni _aeacnl _aeacnr _aeacne _aeacnp _aeacnd _aeacnc _aeacnv _aeacno)
           __:;
    define _aeacn: / style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];;
%end;
%mend prt_exception;
