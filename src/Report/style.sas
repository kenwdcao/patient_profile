

%macro style;


** PDF STYLE TEMPLATE DEFINITION **;
proc template;                                                                
    define style styles.pdfStyle;
    parent = styles.statistical;


    *******************************************************************************************;
    * customizable style attributes 
    *******************************************************************************************;

    class fonts /
        'NormalFont' = ('Courier', 8pt)
        'BoldFont' = ('Courier',8pt, bold)
        'ItalicFont' = ('Courier',8pt, italic)
        'ItalicBolFont' = ('Courier',8pt, italic bold)
        'TitleFont' = fonts('NormalFont')
        'FooterFont' = fonts('NormalFont')
        'HeadingFont' =  fonts('BoldFont')
        'DocFont' = fonts('NormalFont')
     ;

    class colors /
        'border' = cxC1C1C1
        'headerbg' = cxDDEBF7
        'docbg' = white
        'titlebg' = white
        'footerbg' = white
        'titlefg' = cx6F6F6F
        'footerfg' = cx6F6F6F
     ;

    *******************************************************************************************;

    class Container / asis = on;


    class Table/                                                           
        frame = hsides                                                          
        rules = groups
        bordercolor = colors('border')
        borderleftcolor = white
        borderrightcolor = white
        borderleftwidth = 0
        borderrightwidth = 0
        width = 100%
        cellpadding = 8
    ;


    class Header/
        font = fonts('HeadingFont')                                          
        backgroundcolor = colors('headerbg')
        just = l
    ;  

    class Data / just = l;  


    ** works for compute after/before _page_ ;
    style LineContent from Data /  backgroundcolor = colors('docbg');

    style LineContentBefore from LineContent / bordertopcolor = white;
    style LineContentAfter from LineContent / 
        bordertopcolor = white
        borderBottomcolor = white
    ;

    *******************************************************************************************;
    * Titles and Footnots
    *******************************************************************************************;

    class TitlesAndFooters/
        vjust = T 
        just = L 
        paddingtop = 4
        width = 100%
    ;


    class SystemTitle  / 
        backgroundcolor = colors('titlebg') 
        foreground = colors('titlefg')
        font = fonts('TitleFont');
    ;

    class SystemFooter / 
        backgroundcolor = colors('footerbg') 
        foreground = colors('footerfg')
        font = fonts('FooterFont');
    ;


    %if &suppressSysTitle = N %then %do;
    class SystemTitle1 /
        fontweight=bold
        fontsize = 10pt
        vjust = center
    ;

     ** add bottom border for title 2 (patient profile) **;
    class SystemTitle2 /
        borderbottomcolor = colors('border')
        borderbottomwidth = 1
        font = fonts('TitleFont')
        fontweight = bold
        fontsize = 9pt
        paddingbottom = 4
    ;

     ** restore titles **;
     style SystemTitle3 from SystemTitle /
        paddingtop = 4 
    ;
     %end;
    *******************************************************************************************;


   end;                                                                       
run;


** RTF STYLE TEMPLATE DEFINITION **;
proc template;
    define style styles.rtfstyle;
    parent = styles.rtf;

    *******************************************************************************************;
    * customizable style attributes 
    *******************************************************************************************;

    class fonts /
        'NormalFont' = ('Times New Roman ',8pt)
        'BoldFont' = ('Times New Roman',8pt, bold)
        'ItalicFont' = ('Times New Roman',8pt, italic)
        'ItalicBoldFont' = ('Times New Roman',8pt, italic bold)
        'docFont' = fonts('NormalFont')
        'headingFont' = fonts('BoldFont')
        'TitleFont' = fonts('NormalFont')
        'FooterFont' = fonts('NormalFont')
    ;


    class colors /
        'border' = cxAFAFAF 
        'headerbg' = cxDDEBF7
        'docbg' = white
        'titlebg' = white
        'footerbg' = white
        'titlefg' = cx000000
        'footerfg' = cx000000
    ;

    *******************************************************************************************;

    class Container / asis = off;


    class Table/                                                           
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
        just = l
        width = 100%
    ;

    class Header/
        font = fonts('HeadingFont')                                          
        backgroundcolor = colors('headerbg')
        just = l
    ;  

    class Data / just = l;  


    ** works for compute after/before _page_ ;
    style LineContent from Data / backgroundcolor = colors('docbg');

    style LineContentBefore from LineContent;
    style LineContentAfter from LineContent;


    *******************************************************************************************;
    * Titles and Footnots
    *******************************************************************************************;
    class TitlesAndFooters /
        protectspecialchars = off
        paddingtop = 4
        just = left
        asis = on
    ;


    class SystemTitle  / 
        backgroundcolor = colors('titlebg') 
        foreground = colors('titlefg')
        font = fonts('TitleFont')
    ;

    class SystemFooter / 
        backgroundcolor = colors('footerbg') 
        foreground = colors('footerfg')
        font = fonts('FooterFont')
    ;

    %if &suppressSysTitle = N %then %do;
    class SystemTitle1 /
        fontweight = bold
        fontsize = 10pt
        vjust = center
    ;

     ** add bottom border for title 2 (patient profile) **;
     class SystemTitle2/
        borderbottomcolor = colors('border')
        borderbottomwidth = 1
        font=fonts('TitleFont') 
        fontsize = 9pt
        fontweight = bold
        paddingbottom = 4
     ;

     ** restore titles **;
     style SystemTitle3 from SystemTitle / 
        paddingtop = 4
    ;

    %end;
    *******************************************************************************************;


    end;

run;
%mend style;

