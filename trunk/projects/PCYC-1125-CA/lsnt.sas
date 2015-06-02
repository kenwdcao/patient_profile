/*********************************************************************
 Program Nmae: PEABN.sas
  @Author: ZSS
  @Initial Date: 2015/03/16
 


 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc sort data=source.lsnt1 out=s_lsnt1 nodupkey; by _all_; run;
proc sort data=source.lsnt1a out=s_lsnt1a nodupkey; by _all_; run;

proc sort data=source.lsnt2 out=s_lsnt2 nodupkey; by _all_; run;
proc sort data=source.lsnt2a out=s_lsnt2a nodupkey; by _all_; run;


**** Non-Target Lession Assessment (Arm 1) ***;
proc sql;
      create table lsnt1 as
	  select a.*, b.site_id as site_b, b.subid as subid_b, b.id as id_b, b.lsnum, b.lsloc, b.lsdesc 
     from s_lsnt1a as a full join s_lsnt1 as b on a.site_id=b.site_id and a.subid=b.subid and a.parent=b.id;
quit;

data lsnt1_0;
     set lsnt1(rename=(id=__id lsscndtc=in_lsscndtc lsnum=in_lsnum lsloc=in_lsloc
     lsmeth=in_lsmeth lsmeas1a=in_lsmeas1a lsmeas2b=in_lsmeas2b lsdia=in_lsdia lsfdg=in_lsfdg));
	 site_id = coalescec(site_id, site_b);
	 subid = coalescec(subid, subid_b);
	  if __id=. then __id=id_b;

     length subject $255 rfstdtc $10;
     if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
     end;

	  %subject;
      rc = h.find();
      length lsscndtc $20;   
      lsscndtc = in_lsscndtc;
     %concatDY(lsscndtc);

     if in_lsnum^=. then lsnum=strip(put(in_lsnum, lsnum.));
     if in_lsloc^=. then lsloc=strip(put(in_lsloc, lsloc.));
     if in_lsmeth^=. then lsmeth=strip(put(in_lsmeth, lsmeth.));
	 if in_lsmeas1a^=. then lsmeas1a=strip(put(in_lsmeas1a, best.));
	 if in_lsmeas2b^=. then lsmeas2b=strip(put(in_lsmeas2b, best.));
	 if in_lsdia^=. then lsdia=strip(put(in_lsdia, best.));
	 if in_lsfdg^=. then lsfdg=strip(put(in_lsfdg, lsfdg.));
     
	 __arm='Arm 1';
	 keep __arm __id subject lsnum lsloc lsdesc lsscndtc lsmeth lsmethsp lsmeas1a lsmeas2b lsdia lsfdg;
run;

**** Non-Target Lession Assessment (Arm 2) ***;
proc sql;
      create table lsnt2 as
	  select a.*, b.site_id as site_b, b.subid as subid_b, b.id as id_b, b.lsnum, b.lsloc, b.lsdesc 
     from s_lsnt2a as a full join s_lsnt2 as b on a.site_id=b.site_id and a.subid=b.subid and a.parent=b.id;
quit;

data lsnt2_0;
     set lsnt2(rename=(id=__id lsscndtc=in_lsscndtc lsnum=in_lsnum lsloc=in_lsloc
     lsmeth=in_lsmeth lsmeas1a=in_lsmeas1a lsmeas2b=in_lsmeas2b lsdia=in_lsdia lsfdg=in_lsfdg));
	 site_id = coalescec(site_id, site_b);
	 subid = coalescec(subid, subid_b);
	  if __id=. then __id=id_b;

     length subject $255 rfstdtc $10;
     if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
     end;

	  %subject;
      rc = h.find();
      length lsscndtc $20;   
      lsscndtc = in_lsscndtc;
     %concatDY(lsscndtc);

     if in_lsnum^=. then lsnum=strip(put(in_lsnum, lsnum.));
     if in_lsloc^=. then lsloc=strip(put(in_lsloc, lsloc.));
     if in_lsmeth^=. then lsmeth=strip(put(in_lsmeth, lsmeth.));
	 if in_lsmeas1a^=. then lsmeas1a=strip(put(in_lsmeas1a, best.));
	 if in_lsmeas2b^=. then lsmeas2b=strip(put(in_lsmeas2b, best.));
	 if in_lsdia^=. then lsdia=strip(put(in_lsdia, best.));
	 if in_lsfdg^=. then lsfdg=strip(put(in_lsfdg, lsfdg.));
     
	 __arm='Arm 2';
	 keep __arm __id subject lsnum lsloc lsdesc lsscndtc lsmeth lsmethsp lsmeas1a lsmeas2b lsdia lsfdg;
run;

data lsnt;
      set lsnt1_0 lsnt2_0;
run;

proc sort data=lsnt; by subject  lsnum lsscndtc; run;

data pdata.lsnt(label="Non-Target Lesion Assessment");
     retain __id subject lsnum lsloc lsdesc lsscndtc lsmeth lsmethsp lsmeas1a lsmeas2b lsdia lsfdg __arm;
     set lsnt;
	 attrib
     lsnum            label = "Lesion Number"
     lsloc              label = "Location"
     lsdesc            label = "Site Description"
     lsscndtc         label = "Assessment Date"
     lsmeth           label = "Assessment Method"
     lsmeas1a       label = "Measurement 1#(cm)"
     lsmeas2b       label = "Measurement 2#(cm)"
     lsdia              label = "Product of Diameters#(cm&escapechar{super 2})"
     lsfdg              label = "PDG-avid by PET?"
	 ;

	 keep __id subject lsnum lsloc lsdesc lsscndtc lsmeth lsmethsp lsmeas1a lsmeas2b lsdia lsfdg __arm;
run;




