/*
    Program Name: LD.sas
    @Author: Xiu Pan
    @Initial Date: 2015/01/30

    Modification Hisotry:
    Ken Cao on 2015/02/05: Add EGSTAT in final dataset.
    Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
    Ken Cao on 2015/03/05: Concatenate --DY to EGDTC.
*/

%include '_setup.sas';

data ld;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;
    length egdtc $20 egtest $200;
    set source.ld(rename=(visit=visit_ egtim=egtim_ egtm=egtm_ EDC_EntryDate=__EDC_EntryDate));
    %ndt2cdt(ndt=egdt, cdt=egdtc);

    %subject;
        
	rc = h.find();
	%concatDY(egdtc);
	drop rc;

    /*if unsseq^=. then visitnum=input(put(strip(visit_)||''||strip(put(unsseq,best.)),$vnum.),best.);
       else visitnum=input(put(visit_,$vnum.),best.);*/
    if unsseq^=. then visit=strip(visit_)||''||strip(put(unsseq,best.));
        else visit=strip(visit_);
    if egtm_^=. then egtm=put(egtm_,time5.);
        else if egtim_^=. then egtm=put(egtim_,time5.);
    if egorresu ^='' then egtest = strip(egtest)||"#("||strip(egorresu)||")";
    else egtest =  egtest;
    __edc_treenodeid=edc_treenodeid;
    drop edc_:;

    egstat = put(egstat, $checked.);
run;

data ld_;
    length egorres $200 egqtc $100;
    keep __edc_treenodeid __EDC_EntryDate subject visit egdtc egtm egspid egtest egorres egqtc egqtcav egstat ;
    set ld;
    if egclsig^='' then egorres=strip(egclsig);
    if egnd^='' then egorres='Not Done';
    if egqtco^='' then egqtc=strip(egqtc)||': '||strip(egqtco);
run;

************Modify by zhangyan, transpose/2015/02/05*************;
proc sort data = ld_; by subject visit egdtc egtm egspid egqtc egqtcav;run;
proc transpose data = ld_ out = ld_nm(drop = _name_ _label_
        rename = (clinically_significant = clig ventricular_rate__beats_min_ = vr rr_interval__msec_=rr pr_interval__msec_=pr qrs_interval__msec_=qrs qtc__msec_=qtc ));
by subject visit egdtc egtm egspid egqtc egqtcav egstat __edc_treenodeid __EDC_EntryDate;
id egtest;
idlabel egtest;
var egorres;
run;

data ld_nm01(keep = subject visit egdtc egtm egspid egqtc egqtcav qtc egstat __edc_treenodeid __EDC_EntryDate) ld_nm02;
    set ld_nm;
    if qtc ^='' then output ld_nm01;
    else output ld_nm02;
run;

data ld_jn_all;
    merge ld_nm01(rename = (egtm = tmqtc)) ld_nm02(drop = egqtc egqtcav qtc);
    by subject visit egdtc egspid;
run;

/*data ld_nd ld_ld;*/
/*    set ld_;*/
/*    if egstat^='' then output ld_nd;*/
/*        else output ld_ld;*/
/*run;*/
/**/
/*proc sort data=ld_nd out=s_ld_nd nodupkey;by subject visit;run;*/
/**/
/*data ld_nd_1;*/
/*    set s_ld_nd;*/
/*    egorres='Not Done';*/
/*    egtest='';*/
/*run;*/
/**/
/*data ld_all;*/
/*    set ld_ld ld_nd_1;*/
/*run;*/

proc sort data=ld_jn_all; by subject /*visitnum*/ egdtc egspid;run;

data pdata.ld(label='Electrocardiogram');
    retain __edc_treenodeid __EDC_EntryDate subject visit egstat egspid egdtc egtm tmqtc qtc egqtc egqtcav vr rr pr qrs clig;
    keep __edc_treenodeid __EDC_EntryDate subject visit egstat egspid egdtc egtm tmqtc qtc egqtc egqtcav vr rr pr qrs clig;
    set ld_jn_all;
    label
    egdtc='Assessment Date'
    egtm='Assessment Time'
    tmqtc = 'Assessment Time for QTc'
    visit='Visit'
    vr = 'Ventricular rate#(beat/min)';
run;
