/*********************************************************************
 Program Nmae: TL.sas
  @Author: Yan Zhang
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
  
 Ken Cao on 2015/02/05: Removed unit in tumor measurement and put unit
                        in variable labels.
 Ken Cao on 2015/02/05: Split TL into two datasets.
 BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/02/25: Drop SEQ in TL1 and TL2.
 Ken Cao on 2015/03/04: Sort by lesion number first.
*********************************************************************/
%include "_setup.sas";

data tl;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;

    length tldtc  $20 tlmeth $200;
    keep subject seq visit  tlnum tltype tlsite tlsitesp tlnd tlstus tlmeas1_ tlmeas2_ tlpdiam_ tlmeth tlpetyn tlcom seq tldtc 
        __EDC_TreeNodeID __EDC_EntryDate;
    set source.tl(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate));
    %subject;
    tlnd = put(tlnd,$checked.);
    visit = compbl(compress(strip(visit)||" "||strip(put(crseq,best.))||" "||strip(put(pdseq,best.))||" "||strip(put(unsseq,best.)),'.'));

    ** Ken Cao on 2015/02/05: Remove units in tumor measurements;
    
    if tlmeas1^=. and tlmeas1u ^='' then tlmeas1_ =strip( put(tlmeas1,best.))/*||" "||strip(tlmeas1u)*/;
    else if tlmeas1^=. and tlmeas1u = '' then tlmeas1_ =strip( put(tlmeas1,best.));

    if tlmeas2^=. and tlmeas2u ^='' then  tlmeas2_ =strip( put(tlmeas2,best.))/*||" "||strip(tlmeas2u)*/;
    else if tlmeas2^=. and tlmeas2u ='' then  tlmeas2_ =strip( put(tlmeas2,best.));

    if tlpdiam^=. and tlpdiamu ^='' then   tlpdiam_ = strip( put(tlpdiam,best.))/*||" "||strip(tlpdiamu)*/;
    else if tlpdiam^=. and tlpdiamu ='' then   tlpdiam_ = strip( put(tlpdiam,best.));

    if tlmeths ^='' then tlmeth = strip(tlmeth)||": "||strip(tlmeths);
    else tlmeth = strip(tlmeth);
    %ndt2cdt(ndt=tldt, cdt=tldtc);

    rc = h.find();
	%concatDY(tldtc);
	drop rc;

run;

proc sort data = tl; by subject tlnum tldtc ;run;


** Ken Cao on 2015/02/05: Split TL into two datasets;


data pdata.tl1(label = 'Target Lesion Assessment');
    keep __EDC_TreeNodeID __EDC_EntryDate subject  visit tldtc tlnum tltype tlsite tlsitesp tlnd tlstus tlmeas1_ tlmeas2_ tlpdiam_ tlmeth tlpetyn  ;
    retain __EDC_TreeNodeID __EDC_EntryDate subject  visit  tldtc tlnum tltype tlsite tlsitesp tlnd tlstus tlmeas1_ tlmeas2_ tlpdiam_  tlmeth tlpetyn ;
    attrib
    tldtc                        label = 'Assessment Date'
    visit                        label = 'Visit'
    tlmeas1_                     label = 'Measurement 1#(cm)'
    tlmeas2_                     label = 'Measurement 2#(cm)'
    tlpdiam_                     label = "Product of Diameters#(cm&escapechar{super 2})";
    set tl;
run;

data pdata.tl2(label = 'Target Lesion Assessment Comment');
    keep __EDC_TreeNodeID __EDC_EntryDate subject  visit tldtc tlnum tlcom ;
    retain __EDC_TreeNodeID __EDC_EntryDate subject  visit  tldtc tlnum tlcom ;
    set tl;
    if tlcom > ' ';
    label tldtc  = 'Assessment Date';
    label visit  = 'Visit';

run;
