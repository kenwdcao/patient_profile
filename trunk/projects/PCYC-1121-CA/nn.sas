/*********************************************************************
 Program Nmae: NN.sas
  @Author: Xiu Pan
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 LZR on 2015/02/03 add : if nnyn='' .
 Ken Cao on 2015/02/05: Use superscript for 2 in label of nnpdiam.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/04: Sort by lesion number first.
 Ken Cao on 2015/03/05: Concatenate --DY to NNDTC.
*********************************************************************/
%include '_setup.sas';

data nn;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;
    set source.nn(rename=(visit=visit_ nnmeas1=nnmeas1_ nnmeas2=nnmeas2_ nnpdiam=nnpdiam_ EDC_EntryDate=__EDC_EntryDate));
     if nnyn='';
    length nndtc $20;
    %ndt2cdt(ndt=nndt, cdt=nndtc);
    %subject;

	rc = h.find();
	%concatDY(nndtc);
	drop rc;

    if pdseq^=. then visit=strip(visit_)||''||strip(put(pdseq,best.));
        else if unsseq^=. then visit=strip(visit_)||''||strip(put(unsseq,best.));
            else if crseq^=. then visit=strip(visit_)||''||strip(put(crseq,best.));
                else visit=strip(visit_);
    if nnmeas1_^=. then nnmeas1=strip(put(nnmeas1_,best.));
    if nnmeas2_^=. then nnmeas2=strip(put(nnmeas2_,best.));
    if nnpdiam_^=. then nnpdiam=strip(put(nnpdiam_,best.));
    __edc_treenodeid=edc_treenodeid;
    drop edc_:;
run;

data nn_all;
    set nn;
    if nnstus='' and nnnd='Checked' then nnstus='Not Done';
    if nnmethsp^='' then nnmeth=strip(nnmeth)||': '||strip(nnmethsp);
    if nnmeths^='' and nnmeth='' then nnmeth='Method Not Assessed'||': '||strip(nnmeths);
run;

proc sort data=nn_all;by subject /*visitnum*/ nnnum nndt seq;run;

data pdata.nn(label='Nodal Non-Target Lesion Assessment');
    retain __edc_treenodeid __EDC_EntryDate subject visit nnnum nnsite nnsitesp nnstus nnmeas1 nnmeas2 nnpdiam nnmeth nnpetyn nncom nndtc;
    keep __edc_treenodeid __EDC_EntryDate subject visit nnnum nnsite nnsitesp nnstus nnmeas1 nnmeas2 nnpdiam nnmeth nnpetyn nncom nndtc;
    set nn_all;
    label
    nndtc='Assessment Date'
    nnmeas1='Long Axis#(cm)'
    nnmeas2='Short Axis#(cm)'
    /* Ken Cao on 2015/02/05: Use superscript for 2*/
    nnpdiam="Product of Diameters#(cm&escapechar{super 2})"
    visit='Visit'
    ;
run;
