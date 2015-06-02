
** customize PDF style;
proc template;                                                                
    define style styles.pdfstyle2;
    parent = styles.pdfstyle;

    class header /
        backgroundcolor = cxDDEBF7
    ;


   end;                                                                       
run;


** customize RTF style;
proc template;                                                                
    define style styles.rtfstyle2;
    parent = styles.rtfstyle;

    class colors /
        'border' = cxAFAFAF /* use lighter color for border to avoid distraction */
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

    class header /
        backgroundcolor = cxDDEBF7
    ;

   end;                                                                       
run;

