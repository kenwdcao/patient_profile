/*
    For safety patient profile of ARQ 092-101. Adverse Event.
*/

%include '_setup.sas';

proc sql;
    create table ae0 as
    select subid,
        aedesc,
        aestdtc,
        aeemddtc,
        aeongo,
        aeout,
        aenci,
        aesae,
        aecaus,
        aeact,
        aeactoth,
        aeacsp,
        aediscon,
        aedlt,
        m_hlgt,
        m_llt,
        m_pt,
        m_soc,
        m_hlt
    from source.ae
    /*where subid in (select distinct subid from source.ae where aesae=1);*/
    where subid in (select distinct subid from source.ae)   /* useless statement */
    ;
quit;

data ae;
    keep subid aedesc m_pt m_soc aedtc  aeout aenci aesae aecaus aeact aeacnoth __aesae __aedlt 
        aediscon aedlt aestdtc aesae2 aedlt2 ;
    set ae0;
    length aeacnoth $200 __aesae $1 __aedlt $1 aeongo_ $10 aedtc $100;
    %formatDate(AESTDTC);
    %formatDate(AEEMDDTC);
    aeacnoth=coalescec(aeacsp, put(aeactoth,aeactoth.));
    __aesae=strip(put(aesae,best.));
   __aedlt=strip(put(aedlt, best.));
    if aeongo=1 then aeongo_='Ongoing';
    if aeemddtc>'' then aedtc=strip(aestdtc)||"&escapechar{newline}"||aeemddtc;
    else aedtc=strip(aestdtc)||"&escapechar{newline}"||aeongo_;
    label aedesc     = 'Event'
          aestdtc    = 'Onset Date'
          aeemddtc   = 'Stop Date'
          aedtc      = "Start Date#End Date"
          aeacnoth   = 'Other Action Taken'
          aenci      = 'Grade'
          aedlt2     = 'Is AE a DLT'
    ;

    length aesae2 $3 aedlt2 $3;
    label aesae2 = 'SAE';
    label aedlt2 = 'Is AE a DLT';
    if aesae = 1 then aesae2 = 'Yes';
    else if aesae = 0 then aesae2 = 'No';
    if aedlt = 1 then aedlt2 = 'Yes';
    else if aedlt = 0 then aedlt2 = 'No';

run;


proc sort data=ae;by subid aestdtc aedesc;run;
data pdata.ae(label='Adverse Event');
    retain subid aedesc m_pt m_soc aedtc  aeout aenci aesae2 aecaus aeact aeacnoth __aesae  aediscon aedlt2 __aedlt;
    keep subid aedesc m_pt aedtc  aeout aenci aesae2 aecaus aeact aeacnoth __aesae  aediscon aedlt2 __aedlt;
    set ae;
run;
 
