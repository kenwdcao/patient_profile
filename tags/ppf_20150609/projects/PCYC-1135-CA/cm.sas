/*********************************************************************
 Program Nmae: cm.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data cm0;
    set source.cm;
    %subject;
    keep EDC_TreeNodeID SUBJECT	CMTRT CMINDC CMSTDY CMSTMO CMSTYR CMENDY CMENMO CMENYR CMONGO CMROUTE 
         ROUTEOTH CMDSTXT CMDSUNK CMDOSU OTHUNIT CMDOSFRQ OTHFRE CMRSNPP CMRSNMH CMRSNAE CMRSNUD CMSEQ 
         CMMHNO01 CMMHNO02 CMMHNO03 CMAENO01 CMAENO02 CMAENO03 EDC_EntryDate;
run;

data cm1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set cm0;

    length cmstdtc cmendtc _cmongo $20;
    label cmstdtc = 'Start Date';
	label cmendtc = 'End Date';
	label _cmongo = 'Ongoing';
	%concatdate(year=cmstyr, month=cmstmo, day=cmstdy, outdate=cmstdtc);
	%concatdate(year=cmenyr, month=cmenmo, day=cmendy, outdate=cmendtc);
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(cmstdtc);
    %concatDY(cmendtc);
	if cmongo = 'Checked' then _cmongo = 'Yes';
    drop cmstyr cmstmo cmstdy cmenyr cmenmo cmendy;

    length _cmroute _cmdose _cmdosu _cmdosfq $255;
	label _cmroute  = 'Route';
    label _cmdose   = 'Dose';
	label _cmdosu   = 'Units';
	label _cmdosfq  = 'Frequency';
	** Route;
	if find(cmroute, 'Other') and routeoth ^= '' then _cmroute = 'Other (' || strip(routeoth) || ')';
	  else _cmroute = strip(cmroute);
    drop cmroute routeoth;

	** Dose;
	if cmdsunk = 'Checked' then _cmdose = 'Unknown';
	  else _cmdose = strip(cmdstxt);
	drop cmdsunk cmdstxt;

	** Unit;
	if othunit ^= '' then _cmdosu = catx(': ', cmdosu, othunit);
       else _cmdosu = strip(cmdosu); 
    drop cmdosu othunit;

	** Frequency;
    if othfre ^= '' then _cmdosfq = catx(': ', cmdosfrq, othfre);
	  else _cmdosfq = strip(cmdosfrq);


	** Reason for Treatment;
	length mhno01 mhno02 mhno03 aeno01 aeno02 aeno03 _cmrsnpp _cmrsnmh _cmrsnae _cmrsnud $255;
	label _cmrsnpp = "Prophylaxis/Preventative@:Reason for treatment (mark all that apply)"
          _cmrsnmh = "Med History (provide Med Hx #)@:Reason for treatment (mark all that apply)"
          _cmrsnae = "AE (Provide AE #)@:Reason for treatment (mark all that apply)"
          _cmrsnud = "Underlying Disease@:Reason for treatment (mark all that apply)"
         ;

	array t(6) cmmhno01 cmmhno02 cmmhno03 cmaeno01 cmaeno02 cmaeno03;
    array d(6) mhno01 mhno02 mhno03 aeno01 aeno02 aeno03;
	  do i = 1 to 6;
	    if t(i) ^= . then d(i) = strip(put(t(i), best.));
	  end;
	if cmrsnpp = 'Checked' then _cmrsnpp = 'Yes';
	if cmrsnmh = 'Checked' then _cmrsnmh = 'Yes (' || catx(', ', mhno01, mhno02, mhno03) || ')';
	if cmrsnae = 'Checked' then _cmrsnae = 'Yes (' || catx(', ', aeno01, aeno02, aeno03) || ')';
	if cmrsnud = 'Checked' then _cmrsnud = 'Yes';

	drop cmmhno: mhno: cmaeno: aeno:;
run;

proc sort data=cm1; by subject cmstdtc cmendtc cmtrt; run;


data pdata.cm1(label='Concomitant Medication');

    retain EDC_TreeNodeID EDC_EntryDate subject cmseq cmtrt cmindc cmstdtc cmendtc _cmongo _cmroute _cmdose _cmdosu;
    keep   EDC_TreeNodeID EDC_EntryDate subject cmseq cmtrt cmindc cmstdtc cmendtc _cmongo _cmroute _cmdose _cmdosu;

    set cm1;

    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename          cmseq = __cmseq;

run;

data pdata.cm2(label='Concomitant Medication (Continued)');

    retain EDC_TreeNodeID EDC_EntryDate subject cmseq cmtrt _cmdosfq _cmrsnpp _cmrsnmh _cmrsnae _cmrsnud;
    keep   EDC_TreeNodeID EDC_EntryDate subject cmseq cmtrt _cmdosfq _cmrsnpp _cmrsnmh _cmrsnae _cmrsnud;

    set cm1;

    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename          cmseq = __cmseq;

run;
