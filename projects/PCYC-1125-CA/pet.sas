/*********************************************************************
 Program Nmae: PEABN.sas
  @Author: ZSS
  @Initial Date: 2015/03/16
 


 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc sort data=source.pet out=s_pet nodupkey; by _all_; run;
proc sort data=source.pet1 out=s_pet1 nodupkey; by _all_; run;


**** PET Scan ***;
proc sql;
     create table pet_0 as
	 select a.*, b.site_id as site_b, b.subid as subid_b, b.id as id_b, b.petdtc, b.petrs, b.petrsind, b.petmeta
	 from s_pet1 as a full join s_pet as b on a.site_id=b.site_id and a.subid=b.subid and a.parent=b.id;
quit;

data pet;
      set pet_0(rename=(id=__id petdtc=in_petdtc));
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
      length petdtc $20;   
      petdtc = in_petdtc;
     %concatDY(petdtc);

      if petrs^=. then result=strip(put(petrs, petrs.));
      if petmeta^=. then metayn=strip(put(petmeta, noyes.));
      if petsite^=. then site=strip(put(petsite, petsite.));

run;

proc sort data=pet; by subject  petdtc metayn site; run;

data pdata.pet(label="PET Scan");
     retain __id subject petdtc result petrsind metayn site petsp;
     set pet;
	 attrib
     petdtc              label = "Assessment Date"
     result               label = "Result"
     petrsind           label = "If Indeterminate, specify"
     metayn            label = "Any additional metabolically active sites?"
     site                  label = "Positive Site"
     petsp               label = "Description"
	 ;
	 keep __id subject petdtc result petrsind metayn site petsp;
run;




