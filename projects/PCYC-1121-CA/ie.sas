/*********************************************************************
 Program Nmae: IE.sas
  @Author: Huihui Zhang
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/05: Concatenate --DY to IEDTC and IEENRDTC.

*********************************************************************/
%include '_setup.sas';

proc sort data=source.ie out=s_ie nodupkey; by _all_; run;

data ie01;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;

    length ieprot $60 iedtc ieenrdtc $19 ieinc ieexc $200 ;
    set s_ie(rename=(ieprot=in_ieprot ieinc=in_ieinc ieexc=in_ieexc EDC_EntryDate=__EDC_EntryDate));
     %subject;
    array crit(*) ieinc01-ieinc10 ieexc01-ieexc23;
    do i=1 to dim(crit);
        if crit(i)='Checked' then crit(i)="#"||scan(vlabel(crit(i)),2,'#');
    end;
    ieinc=catx(", ", in_ieinc,catx(", ", of ieinc01-ieinc10));
    ieexc=catx(", ", in_ieexc,catx(", ", of ieexc01-ieexc23));
    ieprot=catx(": ",in_ieprot,ieprotv);
    %ndt2cdt(ndt=iedt, cdt=iedtc);
    %ndt2cdt(ndt=ieenrdt, cdt=ieenrdtc);

	rc = h.find();
	%concatDY(iedtc);
	%concatDY(ieenrdtc);
	drop rc;

    __edc_treenodeid=edc_treenodeid;
    drop edc_: i;
run;

proc sort data=ie01; by subject; run;

data pdata.ie(label="Informed Consent / Eligibility");
    retain __edc_treenodeid __EDC_EntryDate subject iedtc ieprot ieottc ieinc ieexc ieenryn ieenrdtc ;
    keep __edc_treenodeid __EDC_EntryDate subject iedtc ieprot ieottc ieinc ieexc ieenryn ieenrdtc ;
    set ie01;
    label 
        ieinc = 'Inclusion Criteria met'
        ieexc = 'Exclusion Criteria met'
        iedtc = 'Informed Consent Date'
        ieenrdtc = 'Date of Enrollment Approval'
        ieprot = 'Protocol Version Subject Enrolled Under'
    ;
run;
