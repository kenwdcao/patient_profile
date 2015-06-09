/********************************************************************************
 Program Nmae: prt_exception.sas
  @Author: 
  @Initial Date: 2015/04/22
 
 Interface to let user alter proc report statements.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/

%macro prt_exception();
%if %upcase(&dset) = QLAB1 %then %do;
    define CD3 /  style(column)=[width=9%];
    define CD3LY /  style(column)=[width=9%];
    define CD4 /  style(column)=[width=9%];
    define CD4LY /  style(column)=[width=9%];
    define CD8 /  style(column)=[width=9%];
    define CD8LY /  style(column)=[width=9%];
%end;
%else %if %upcase(&dset) = QLAB2 %then %do;
    define CD19 /  style(column)=[width=9%];
    define CD19LY /  style(column)=[width=9%];
    define CD19ECC /  style(column)=[width=9%];
    define CD19EV /  style(column)=[width=9%];
    define CD1656 /  style(column)=[width=9%];
    define CD1656LY /  style(column)=[width=9%];
%end;
%mend prt_exception;
