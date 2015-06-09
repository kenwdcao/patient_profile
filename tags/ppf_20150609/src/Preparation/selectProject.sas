

*******************************************************************************;
*SAS Window Enviornment:                                                      *;
*******************************************************************************;


%macro selectProject();  /*returns project name (folder name) as macro variable: whichProject*/


%local wrontcnt; /*counter: # of times user input a wrong project name. */
%local rootdir2; /*Root directory of patient profiles*/


%let wrontcnt = 0;


/*
    Setup a temporary library reference to the directory of this program locates --- root directory.
*/
libname dummy ".";
%let rootdir2 = %sysfunc(pathname(dummy));
libname dummy clear;




%CHOOSEPROJECT:
data _null_;
    length whichProject $32;
    whichProject = "&whichProject";
    window whichProject color = white icolumn = 5 irow = 5 columns = 120 rows = 25
        #3 @35 " Welcome to Use Q2 Patient Profile Application "    attr = rev_video color = green
        #5 @5  "Please INPUT name of project here: " color = blue whichProject required = yes 
        #7 @5  "Press Enter or issue ""End"" command in command line at top left corner to exit this window" color = green
    ;
    display whichProject;
    call symput('whichProject', strip(whichProject));
    stop;
run;


/*
    interactive window: if project name user input was not found under project folder, ask user to correct input.
*/ 

%ValidateProject:
%let whichProject = %trim(&whichProject);
%if %sysfunc(fileexist(&rootdir2/projects/&whichProject)) = 0 %then
%do;
    %let wrontcnt = %eval(&wrontcnt+1);
    data _null_;
        window wrongProject color = white icolumn=5 irow = 5    columns = 180 rows = 25
            #3  @35 " Something's not right...  " attr = rev_video color = red
            #5  @5  "Your input: %lowcase(&whichProject) is not found under folder"
            #7  @7  "&rootdir2\projects"
            #9  @5  "Press Enter to go back to Welcome Window to re-input the name of setup program." color=green
            ;
        display wrongProject;
        stop;
    run;

    /*
        program will stop processing after 5 times of incorrect project name
    */
    %if &wrontcnt < 5 %then %goto CHOOSEPROJECT;
    %else
    %do;
        data _null_;
        window forceexit color = white icolumn = 5 irow = 5   columns = 180 rows = 25
            #3  @35 " Sorry...  " attr = rev_video color = red
            #5  @5  "The project name you input is still not found." 
            #7  @5  "Please go to plugin folder to check if any spelling err&blank.or." 
            #9  @5  "Then, please make sure current work directory for this SAS session:"
            #11 @7  " &rootdir2 " color = blue
            #13 @5  "is the root directory of Patient Profile Application" 
            #13 @5  "Press Enter to stop running and start again" 
            #15 @5  "If this window keeps arising, please contact your local expert." color = green
            #17 @5  "Goodbye!" color = green
            ;
        display forceexit;
        stop;
    run;
    %end;
    %return;
%end;
%else 
%do;
    
    /*
       information window:Notify user input is correct. Program will start processing later.
    */

    data _null_;
        window success
            color = white
            icolumn = 5   irow = 5
            columns = 150 rows = 25
            #3 @35 "Congratulations!" attr=rev_video color=red
            #5 @5  "Your Patient Profiles are On the Way." color=green
            #7 @5  "Please Press Enter to Exit This Window and Start Execution." color=green
            #9 @5  "Enjony!" color=green
        ;
        display success;
        stop;
    run;
%end;

%mend selectProject;
