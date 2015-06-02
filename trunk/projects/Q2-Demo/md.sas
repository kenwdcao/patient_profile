/*********************************************************************
 Program Nmae: MD.sas
  @Author: Huihui Zhang
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/05: Split MD into two datasets.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/04: 1) Change MDPDNONE label to "Refractory to last therapy".
                        2) Display UNK and NULL for MDDTC.
 Ken Cao on 2015/03/05: Concatenate --DY to MDDTC.

*********************************************************************/
%include '_setup.sas';

proc sort data=source.md out=s_md nodupkey; by _all_; run;

data md01;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;

    length mddtc $19 mdpdnl mdtsym mdtoth $200;
    set s_md(rename=(EDC_EntryDate=__EDC_EntryDate));
    %subject;
    array md(*) mdp: mdt:;
    do i=1 to dim(md);
        if md(i)='Checked' then md(i)=put(md(i),$checked.);
/*        if index(vname(md(i)),'MDP') then vlabel(md(i))=substr(vlabel(md(i)),length("Evidence for PD")+2);*/
/*        else if index(vname(md(i)),'MDT') then vlabel(md(i))=substr(vlabel(md(i)),length("Evidence for Need Tx")+2);*/
    end;
    %concatDateV2(year=mdyy, month=mdmm, day=mddd, outdate=mddtc);
	rc = h.find();
	%concatDY(mddtc);
	drop rc;
    mdpdnl=catx(", ",mdpdnl,mdpdnls);
    mdtsym=catx(", ",mdtsym,mdtsyms);
    mdtoth=catx(", ",mdtoth,mdtoths);
    __edc_treenodeid=edc_treenodeid;
    drop edc_: i;
run;

/*Change label for variable mdp: mdt:*/
proc contents data=md01 out=label(keep=name label) noprint; run;

proc sql noprint;
    select strip(name)||" = '"||strip(substr(label,length("Evidence for PD")+2))||"'" into: label1 
    separated by " " 
    from label
    where substr(name,1,3)='MDP';
    select strip(name)||" = '"||strip(substr(label,length("Evidence for Need Tx")+2))||"'" into: label2 
    separated by " " 
    from label
    where substr(name,1,3)='MDT';
quit;
/*End: Change label for variable mdp: mdt:*/

proc sort data=md01; by subject; run;



** Ken Cao on 2015/02/05: Split MD into two datasets.;

data pdata.md1(label="MZL Disease History");
    retain __edc_treenodeid __EDC_EntryDate subject mddtc mdstype mdpdnone mdpdl mdpdnl  mdpdnlbp mdpdoth mdpdoths;
    keep __edc_treenodeid __EDC_EntryDate subject mddtc mdstype mdpdnone mdpdl mdpdnl mdpdnlbp mdpdoth mdpdoths;
    set md01;
    label &label1 &label2
        mddtc = 'Date of Initial Diagnosis'
        mdpdoths = 'Specify Details'
        mdpdnl = 'New Lesion#Specify location'
        mdpdnlbp = 'New Lesion#Biopsy confirmed'
        mdpdoth ='Other'
        mdpdnone="Refractory to last therapy"
    ;
run;



data pdata.md2(label="MZL Disease History (Continued)");
    retain __edc_treenodeid __EDC_EntryDate subject mddtc mdstype mdtt mdtbd mdtsym  mdtrt mdtrgf mdtoth;
    keep __edc_treenodeid __EDC_EntryDate subject mddtc mdstype mdtt mdtbd mdtsym  mdtrt mdtrgf mdtoth;
    set md01;
    label &label1 &label2
        mddtc = 'Date of Initial Diagnosis'
        mdpdoth = 'Other'
        mdtt = 'Threatened end-organ function'
        mdtrt = 'Requires transfusions'
        mdtrgf = 'Requires growth factor support'
    ;
run;
