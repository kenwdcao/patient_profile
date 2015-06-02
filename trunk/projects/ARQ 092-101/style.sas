/*
    customize pdf style.
*/


proc template;                                                                
    define style styles.pdfstyle2;
    parent = styles.pdfstyle;


    ** display bottom border for title2 **; 
    class SystemTitle2/
        borderbottomcolor = colors('border')
        borderbottomwidth = 1
    ;

    ** restore title3 **; 
    style SystemTitle3 from TitlesAndFooters;


    /*
    ** display bottom border for title4 **; 
    class SystemTitle4/
        borderbottomcolor = colors('border')
        borderbottomwidth = 1
    ;

    ** restore the rest titles **; 
    style SystemTitle5 from TitlesAndFooters;
    */

   end;                                                                       
run;



proc template;                                                                
    define style styles.rtfstyle2;
    parent = styles.rtfstyle;

    class colors /
        'border' = cx3F3F3F /* use lighter color for border to avoid distraction */
    ;

    class table /
        frame = box
        rules = all
        bordertopwidth = 1
        borderleftwidth = 1
        borderrightwidth = 1
        borderbottomwidth = 1
        bordercolor = colors('border')
        bordertopcolor = colors('border')
        borderleftcolor = colors('border')
        borderrightcolor = colors('border')
        borderbottomcolor = colors('border')
        ;


    ** display bottom border for title2 **; 
    class SystemTitle2/
        borderbottomcolor = colors('border')
        borderbottomwidth = 1
    ;

    ** restore the rest of titles **; 
    style SystemTitle3 from TitlesAndFooters;

   end;                                                                       
run;

