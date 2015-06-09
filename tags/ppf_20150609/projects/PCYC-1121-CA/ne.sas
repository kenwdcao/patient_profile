/*********************************************************************
 Program Nmae: NE.sas
  @Author: Xiu Pan
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 LZR on 2015/02/03
 Ken Cao on 2015/02/05: Use superscript for 2 in label of nepdiam.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/04: Sort by lesion number first.
 Ken Cao on 2015/03/05: Concatenate --DY to NEDTC.

*********************************************************************/
%include '_setup.sas';

data ne;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;
    set source.ne(rename=(visit=visit_ nemeas1=nemeas1_ nemeas2=nemeas2_ nepdiam=nepdiam_ EDC_EntryDate=__EDC_EntryDate));
     if neyn='';
    length nedtc $20;
    %ndt2cdt(ndt=nedt, cdt=nedtc);
    %subject;

	rc = h.find();
	%concatDY(nedtc);
	drop rc;

    if pdseq^=. then visit=strip(visit_)||''||strip(put(pdseq,best.));
        else if unsseq^=. then visit=strip(visit_)||''||strip(put(unsseq,best.));
            else if crseq^=. then visit=strip(visit_)||''||strip(put(crseq,best.));
                else visit=strip(visit_);
    if nemeas1_^=. then nemeas1=strip(put(nemeas1_,best.));
    if nemeas2_^=. then nemeas2=strip(put(nemeas2_,best.));
    if nepdiam_^=. then nepdiam=strip(put(nepdiam_,best.));
    __edc_treenodeid=edc_treenodeid;
    drop edc_:;
run;

data ne_all;
    set ne;
    if nestus='' and nend='Checked' then nestus='Not Done';
    if nemethsp^='' then nemeth=strip(nemeth)||': '||strip(nemethsp);
    if nemeths^='' and nemeth='' then nemeth='Method Not Assessed'||': '||strip(nemeths);
run;

proc sort data=ne_all;by subject /*visitnum*/ nenum nedt seq;run;

data pdata.ne(label='Extranodal Non-Target Lesion Assessment');
    retain __edc_treenodeid __EDC_EntryDate subject visit nenum nesitesp nestus nemeas1 nemeas2 nepdiam nemeth nepetyn necom nedtc;
    keep __edc_treenodeid __EDC_EntryDate subject visit nenum nesitesp nestus nemeas1 nemeas2 nepdiam nemeth nepetyn necom nedtc;
    set ne_all;
    label
    nedtc='Assessment Date'
    nemeas1='Long Axis#(cm)'
    nemeas2='Short Axis#(cm)'
    nepdiam="Product of Diameters#(cm&escapechar{super 2})"
    visit='Visit'
    ;
run;
