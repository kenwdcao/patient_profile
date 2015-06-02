/********************************************************************************
 Program Nmae: prt_exception.sas
  @Author: 
  @Initial Date: 2015/02/26
 
 Interface to let user alter proc report statements.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/

%macro prt_exception();

/*  Example 
%if %upcase(&dset) = DM %then %do;
   column birthdtc cbp ("&escapechar.S={just=c}If No, Specify Reason" cbpn01 cbpn02 cbpn04 cbpn03 cbpn05 cbpno) ethnic race country __:;
   define cbpn:/ style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];
%end;
*/
%if %upcase(&dset) = ECOG %then %do;
    define visit / style(column)={cellwidth=1.5in };
    define ecogstat / style(column)={cellwidth=3.7in };
    define ECOGINV / style(column)={cellwidth=3.3in };
%end;
/*
%else %if %upcase(&dset) = ECG2 %then %do;
    define heartrt / format=miss10.;
    define qrs / format=miss10.;
    define rrint / format=miss10.;
    define qtint / format=miss10.;
    define print / format=miss10.;
    define qtc / format=miss10.;
%end;
*/
%mend prt_exception;
