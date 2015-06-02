/*********************************************************************
 Program Nmae: img.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data img0;
    set source.img;
    %subject;
    keep EDC_TreeNodeID SUBJECT VISIT CYCLE IMGGRID IMGMETHD IMGLOC IMLOCOSP IMGMRI MRIOTHSP PETORSLT UNSSEQ 
         SEQ IMGDAT IMINDTSP EDC_EntryDate;
run;


data img1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set img0;
	%visit2;
    length imgdtc $20;
	label  imgdtc = 'Assessment Date';
	%ndt2cdt(ndt=imgdat, cdt=imgdtc);
	rc = h.find();
	drop rc rfstdtc;
    %concatDY(imgdtc);

	label imlocosp = 'Other Specify'
	        imgmri = 'If MRI, specify reason'
          mriothsp = 'Other Specify'
          petorslt = 'If PET or PET/CT, Overall Result'
          imindtsp = 'Indeterminate Specify'
		;
run;

proc sort data = img1; by subject imggrid imgdtc; run;

data pdata.img(label='Imaging Assessment');
    retain EDC_TreeNodeID EDC_EntryDate subject visit2 seq imggrid imgdtc imgmethd imgloc imlocosp imgmri mriothsp petorslt imindtsp; 
    keep   EDC_TreeNodeID EDC_EntryDate subject visit2 seq imggrid imgdtc imgmethd imgloc imlocosp imgmri mriothsp petorslt imindtsp; 

    set img1;
	where imgdtc ^= ''; 
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename            seq = __seq;
run;
