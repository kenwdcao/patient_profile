/*********************************************************************
 Program Nmae: PEABN.sas
  @Author: ZSS
  @Initial Date: 2015/03/16
 


 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc sort data=source.vs1 out=s_vs1 nodupkey; by _all_; run;
proc sort data=source.vs2 out=s_vs2 nodupkey; by _all_; run;

**** vital signs ***;
data vsall;
      set s_vs1 s_vs2;
run;

data vs;
     length subject $255 rfstdtc $10;
     if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
     end;

     set vsall(rename=(id=__id vsnd=in_vsnd vsdtc=in_vsdtc));

    %subject;
	   rc = h.find();
      length vsdtc $20;   
      vsdtc = in_vsdtc;
     %concatDY(vsdtc);

	if in_vsnd=1 then vsnd="Yes";

	length temp_a $200;
	if temp^=. then do; temp_c=strip(put(temp, best.)); end;
	if torresu^=. then do; temp_u=strip(put(torresu, torresu.)); end;
	if tmpnd^=. then do; temp_nd="Not Done"; end;
    temp_=strip(temp_c)||' '||strip(temp_u);
	if temp_^='' and temp_nd^='' then do; temp_a=strip(temp_)||' | '||strip(temp_nd); end;
	   else do; temp_a=strip(coalescec(temp_, temp_nd)); end;

	length hrate_a $200;
	if hrate^=. then do; hrate_c=strip(put(hrate, best.)); end;
	if hratend^=. then do; hrate_nd="Not Done"; end;
	if hrate_c^='' and hrate_nd^='' then do; hrate_a=strip(hrate_c)||' | '||strip(hrate_nd); end;
	   else do; hrate_a=strip(coalescec(hrate_c, hrate_nd)); end;

	length rrate_a $200;
	if rrate^=. then do; rrate_c=strip(put(rrate, best.)); end;
	if rratend^=. then do; rrate_nd="Not Done"; end;
	if rrate_c^='' and rrate_nd^='' then do; rrate_a=strip(rrate_c)||' | '||strip(rrate_nd); end;
	   else do; rrate_a=strip(coalescec(rrate_c, rrate_nd)); end;

	length bp_a $200;
	if sysbp^=. then do; sysbp_c=strip(put(sysbp, best.)); end;
	if diabp^=. then do; diabp_c=strip(put(diabp, best.)); end;
	if bpnd^=. then do; bp_nd="Not Done"; end;
	if cmiss(sysbp_c, diabp_c)<2 then bp=strip(sysbp_c)||' / '||strip(diabp_c);
	if bp^='' and bp_nd^='' then do; bp_a=strip(bp)||' | '||strip(bp_nd); end;
	   else do; bp_a=strip(coalescec(bp, bp_nd)); end;

	length weight_a $200;
	if weight^=. then do; weight_c=strip(put(weight, best.)); end;
	if wtorresu^=. then do; weight_u=strip(put(wtorresu, wtorresu.)); end;
	if wtnd^=. then do; wt_nd="Not Done"; end;
    weight_=strip(weight_c)||' '||strip(weight_u);
	if weight_^='' and wt_nd^='' then do; weight_a=strip(weight_)||' | '||strip(wt_nd); end;
	   else do; weight_a=strip(coalescec(weight_, wt_nd)); end;

	length height_a $200;
	if height^=. then do; height_c=strip(put(height, best.)); end;
	if htorresu^=. then do; height_u=strip(put(htorresu, htorresu.)); end;
	if htnd^=. then do; ht_nd="Not Done"; end;
    height_=strip(height_c)||' '||strip(height_u);
	if height_^='' and ht_nd^='' then do; height_a=strip(height_)||' | '||strip(ht_nd); end;
	   else do; height_a=strip(coalescec(height_, ht_nd)); end;

run;

proc sort data=vs; by subject  vsdtc event_no ; run;

data pdata.vs(label="Vital Signs");
     retain __id subject __event_no event_id vsnd vsdtc temp_a hrate_a rrate_a bp_a weight_a height_a;
     set vs (rename=(event_no=__event_no));
	 attrib
     event_id          label = "Visit"
     vsdtc              label = "Assessment Date"
     vsnd                label = "Not Done"
     temp_a             label = "Temperature"
     hrate_a             label = "Heart Rate#(beats/min)"
     rrate_a             label = "Respiratory Rate#(breaths/min)"
     bp_a               label = "Blood Pressure Systolic/Diastolic#(mmHg)"
     weight_a             label = "Weight"
     height_a             label = "Height"

	 ;
	 keep __id subject __event_no event_id vsdtc vsnd temp_a hrate_a rrate_a bp_a weight_a height_a;
run;




