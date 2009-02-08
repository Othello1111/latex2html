# $Id: french.perl,v 1.8 1998/02/23 11:59:29 latex2html Exp $
# FRENCH.PERL by Nikos Drakos <nikos@cbl.leeds.ac.uk> 25-11-93
# Computer Based Learning Unit, University of Leeds.
#
# Extension to LaTeX2HTML to translate LaTeX french special 
# commands to equivalent HTML commands and ISO-LATIN-1 characters.
# Based on a patch to LaTeX2HTML supplied by  Franz Vojik 
# <vojik@de.tu-muenchen.informatik>. 
#
# Change Log:
# ===========
# $Log: french.perl,v $
# Revision 1.8  1998/02/23 11:59:29  latex2html
# *** empty log message ***
#
# Revision 1.7  1998/02/23 11:48:17  latex2html
#  -- in language-titles, use TeX accent-macros, rather than entities
#
# Revision 1.6  1998/02/23 02:26:41  latex2html
#  --  replaced  &get_date  by  &get_date()
#         error reported with SunOS (thanks Yannick Patois)
#  --  added some more $GENERIC_WORDS
#
# Revision 1.4  1998/02/22 05:27:08  latex2html
# revised &german|french_titles
#
# Revision 1.3  1998/02/16 03:33:12  latex2html
#  --  provided $GENERIC_WORDS to be omitted from filenames derived from
# 	section-titles, when using  -long_titles
#
# Revision 1.2  1996/12/23 01:39:54  JCL
# o added informative comments and CVS log history
# o changed usage of <date> to an OS independent construction, the
#   patch is from Piet van Oostrum.
#
#
# 11-MAR-94 Nikos Drakos - Added support for \inferieura and \superrieura

package french;

# Put french equivalents here for headings/dates/ etc when
# latex2html start supporting them ...

sub main'french_translation {
    @_[0];
}

package main;

sub do_cmd_frenchTeX {
    # Just in case we pass things to LaTeX
    $default_language = 'french';
    $latex_body .= "\\frenchTeX\n";
    @_[0];
}

sub do_cmd_originalTeX {
    # Just in case we pass things to LaTeX
    $default_language = 'original';
    $latex_body .= "\\originalTeX\n";
    @_[0];
}

sub do_cmd_inferieura {
   "&lt @_[0]"
}
 
sub do_cmd_superrieura {
   "&gt @_[0]"
}

#AYS: Prepare the french environment ...
sub french_titles {
    $toc_title = "Table des mati{\`e}res";
    $lof_title = "Liste des figures";
    $lot_title = "Liste des tableaux";
    $idx_title = "Index";
    $ref_title = "R{\'e}f{\'e}rences";
    $bib_title = "R{\'e}f{\'e}rences";
    $abs_title = "R{\'e}sum{\'e}";
    $app_title = "Annexe";
    $pre_title = "Pr{\'e}face";
    $fig_name = "Figure";
    $tab_name = "Tableau";
    $part_name = "Partie";
    $prf_name = "Preuve";
    $child_name = "Sous-sections";
    $info_title = "{\`A} propos de ce document..."; 
    @Month = ('', 'janvier', 'f{\'e}vrier', 'mars', 'avril', 'mai',
              'juin', 'juillet', 'ao{\^u}t', 'septembre', 'octobre',
              'novembre', 'd{\'e}cembre');
    $GENERIC_WORDS = "a|au|aux|mais|ou|et|donc|or|ni|car|l|la|le|les"
	. "|c|ce|ces|un|une|d|de|du|des";
}

#AYS(JKR): Replace do_cmd_today (\today) with a nicer one, which is more
# similar to the original. 
#JCL introduced &get_date.
sub do_cmd_today {
    local($today) = &get_date();
    $today =~ s|(\d+)/0?(\d+)/|$2 $Month[$1] |;
    join('',$today,$_[0]);
}

# ... and use it.
&french_titles;
$default_language = 'french';
$TITLES_LANGUAGE = "french";

1;				# Not really necessary...



