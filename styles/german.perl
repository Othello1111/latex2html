# $Id: german.perl,v 1.6 1997/06/13 13:54:50 RRM Exp $
# GERMAN.PERL by Nikos Drakos <nikos@cbl.leeds.ac.uk> 25-11-93
# Computer Based Learning Unit, University of Leeds.
#
# Extension to LaTeX2HTML to translate LaTeX german special 
# commands to equivalent HTML commands.
# Based on a patch to LaTeX2HTML supplied by  Franz Vojik 
# <vojik@de.tu-muenchen.informatik>. 
#
# The original german.sty file was put together by H.Partl 
# (TU Wien) 4 Nov 1988
#
# Change Log:
# ===========
# $Log: german.perl,v $
# Revision 1.6  1997/06/13 13:54:50  RRM
#     Allow  &#34;  to be translated back into  \dq{}
#
# Revision 1.5  1997/06/06 12:49:09  RRM
#  -  Fixed the handling of umlauts
#  -  used ISO-Latin characters for `french quotes'
#  -  changed version info
#
# Revision 1.4  1997/05/19 13:34:27  RRM
#     Fixed a problem with umlauts.
#
# Revision 1.3  1996/12/23 01:39:55  JCL
# o added informative comments and CVS log history
# o changed usage of <date> to an OS independent construction, the
#   patch is from Piet van Oostrum.
#
#
# 11-JAN-94 Nikos Drakos: Modified the german specials array to
#           deal with "` correctly
# 25-JAN-94 Nikos Drakos: Replaced all the html special characters
#           with their ;tex2html_html_special_mark_<chars> form
# 13-Dec-94 Nikos Drakos Replaced ;tex2html_html_special_mark_<char>; with
#           ;SPM<char>; to be consistent with changes in the main script
# 19-Dec-95 Herb Swan: Removed _ from SPM... definitions, consistent with
#	    with new math code of Marcus Hennecke.  Ignore '"|' and '"-'.
# 23-May-97 Ross Moore: the " searches were out of order, so some cases
#	    would never be found. 
#           Treat "s "z and "S "Z differently; thanks to  Marcus Harnisch.
#           Replace non-special ;SPMquot; by  &#34; 

package german;
#JKR: print a message.
print "german style interface for LaTeX2HTML, revised: 23 May 1997\n";

# Put german equivalents here for headings/dates/ etc when
# latex2html start supporting them ...


sub main'german_translation {
    local($_) = @_;
    s/;SPMquot;\s*(;SPMlt;|;SPMgt;|'|`|\\|-|=|;SPMquot;|\||~)/&get_german_specials($1)/geo;
    local($next_char_rx) = &make_next_char_rx("[aAeEiIoOuU]");
    s/$next_char_rx/&main'iso_map(($2||$3),"uml")/geo;
#    $next_char_rx = &make_next_char_rx("[sSzZ]");
    $next_char_rx = &make_next_char_rx("[sz]");
    s/$next_char_rx/&main'iso_map("sz","lig")/geo;
    $next_char_rx = &make_next_char_rx("[SZ]"); s/$next_char_rx/S$2/go;
    s/;SPMquot;\s*([cflmnprt])/\1/go;
#    s/;SPMquot;\s*([cflmnpt])/\1/go;
#    s/;SPMquot;\s*(;SPMlt;|;SPMgt;|'|`|\\|-|;SPMquot;|\||~)/&get_german_specials($1)/geo;
#    s/;SPMquot;/''/go;
    s/;SPMquot;/&#34;/go;
    $_;
}

sub main'do_cmd_3 {
    join('',&main'iso_map("sz", "lig"),@_[0]);
}

sub make_next_char_rx {
    local($chars) = @_;
    local($OP,$CP) = &main'brackets;
    ";SPMquot;\\s*(($chars)|$OP\\d+$CP\\s*($chars)\\s*$OP\\d+$CP)";
}
   
sub get_german_specials {
    $german_specials{@_[0]}
}

%german_specials = (
    '\'', "``",
    "\`", ",,",
    '\\', "",
    '-', "",
    '|', "",
    ';SPMquot;', "",
    '~', "-",
    '=', "-"
);

if ($CHARSET =~ /iso_8859_2/) {
    if ($HTML_VERSION > 2.1) {
%german_specials = (
      ';SPMlt;', '<SMALL>;SPMlt;;SPMlt;</SMALL>'    
    , ';SPMgt;', '<SMALL>&#62;&#62;</SMALL>'
    , %german_specials );
    } else {
%german_specials = (
      ';SPMlt;', ';SPMlt;;SPMlt;'    
    , ';SPMgt;', '&#62;&#62;'
    , %german_specials );
    }
} else {
%german_specials = (
      ';SPMlt;', '&#171;'    
    , ';SPMgt;', '&#187;'
    , %german_specials );
}


package main;

sub do_cmd_flqq {
    if ($CHARSET =~ /iso_8859_2/) {
	if ($HTML_VERSION > 2.1) {
	    join('', '<SMALL>;SPMlt;;SPMlt;</SMALL>',  @_[0]) }
	else { join('',  ';SPMlt;;SPMlt;',  @_[0]) }
    } else { join('',  '&#171;',  @_[0]) }
}
sub do_cmd_frqq {
    if ($CHARSET =~ /iso_8859_2/) {
	if ($HTML_VERSION > 2.1) {
	    join('', '<SMALL>&#62;&#62;</SMALL>',  @_[0]) }
	else { join('',  '&#62;&#62;',  @_[0]) }
    } else { join('',  '&#187;',  @_[0]) }
}
sub do_cmd_flq {
    if ($HTML_VERSION > 2.1) {
	join('', '<SMALL>;SPMlt;</SMALL>',  @_[0]) }
    else { join('',  ';SPMlt;',  @_[0]) }
}
sub do_cmd_frq {
    if ($HTML_VERSION > 2.1) {
	join('', '<SMALL>&#62;</SMALL>',  @_[0]) }
    else { join('',  '&#62;',  @_[0]) }
}
sub do_cmd_glqq {
    join('',  ",,",  @_[0]);};
sub do_cmd_grqq {
    join('',  "``",  @_[0]);};
sub do_cmd_glq {
    join('',  ",",  @_[0]);};
sub do_cmd_grq {
    join('',  "`",  @_[0]);};
sub do_cmd_dq {
#    join('',  "''",  @_[0]);};
    join('',  '&#34;',  @_[0]);};

sub do_cmd_germanTeX {
    # Just in case we pass things to LaTeX
    $default_language = 'german';
    $latex_body .= "\\germanTeX\n";
    @_[0];
}

sub do_cmd_originalTeX {
    # Just in case we pass things to LaTeX
    $default_language = 'original';
    $latex_body .= "\\originalTeX\n";
    @_[0];
}

#JKR: Prepare the german environment ...
sub german_titles {
    $toc_title = "Inhalt";
    $lof_title = "Abbildungsverzeichnis";
    $lot_title = "Tabellenverzeichnis";
    $idx_title = "Index";
    $bib_title = "Literatur";
    $abs_title = "Zusammenfassung";
    $pre_title = "Vorwort";
    $app_title = "Anhang";
    $fig_name = "Abbildung";
    $tab_name = "Tabelle";
    $info_title = "&Uuml;ber dieses Dokument ...";
    @Month = ('', 'Januar', 'Februar', 'M&auml;rz', 'April', 'Mai',
	      'Juni', 'Juli', 'August', 'September', 'Oktober',
	      'November', 'Dezember');  
}

#JKR: Replace do_cmd_today (\today) with a nicer one, which is more
# similar to the original. 
#JCL introduced &get_date
sub do_cmd_today {
    local($today) = &get_date;
    $today =~ s|(\d+)/0?(\d+)/|$2. $Month[$1] |;
    join('',$today,$_[0]);
}

# ... and use it.
&german_titles;
$default_language = 'german';
$TITLES_LANGUAGE = "german";

# MEH: Make iso_latin1_character_map_inv use more appropriate code
$iso_latin1_character_map_inv{'&#171;'} ='\\flqq';
$iso_latin1_character_map_inv{'&#187;'} ='\\frqq';
$iso_latin1_character_map_inv{'&#196;'} ='"A';
$iso_latin1_character_map_inv{'&#214;'} ='"O';
$iso_latin1_character_map_inv{'&#220;'} ='"U';
$iso_latin1_character_map_inv{'&#228;'} ='"a';
$iso_latin1_character_map_inv{'&#246;'} ='"o';
$iso_latin1_character_map_inv{'&#223;'} ='"s';
$iso_latin1_character_map_inv{'&#252;'} ='"u';
$iso_latin1_character_map_inv{'&#34;'} ='\\dq{}';

1;				# Not really necessary...



