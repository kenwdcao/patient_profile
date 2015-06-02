%include '_setup.sas';

data pk0;
  length subjid part daypk $20 pktpt $60;
  set source.pk_samplesamples(rename=(daypk=daypk_));
  if ssid^='' then subjid=strip(ssid);
  if partpk_label^='' then part=strip(scan(partpk_label, 2, ''));
  daypk=strip(daypk_label);
  if substr(timpnt_label,1,1)='.' then pktpt='0'||strip(timpnt_label); else pktpt=strip(timpnt_label);
run;

proc sort data = pk0; by subjid daypk_ timpnt acttime; run;

data pdata.pk(label='PK Samples');
   retain SUBJID PART DAYPK PKTPT ACTTIME PKACCN;
   set pk0;
   label subjid='Subject No.'
          part='Part'
          daypk='Day'
		  pktpt='Time Point'
		  acttime='Actual Time'
          pkaccn='Accession Number';
  keep subjid part daypk pktpt acttime pkaccn;
run;
