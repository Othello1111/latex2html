#
# $Id: html.perl 12004 2004-02-20 13:13:29Z nxg $
#
# HTML.PERL by Nikos Drakos <nikos@cbl.leeds.ac.uk> 2-DEC-93
# Computer Based Learning Unit, University of Leeds.
#
# Extension to LaTeX2HTML to translate hypermedia extensions
# to LaTeX defined in html.sty to equivalent HTML commands.
#
#
#
# Modifications (Initials see Changes):
#
# $Log$
# Revision 1.1  2004/02/20 13:13:28  nxg
# Initial import
#
# Revision 1.30  1998/06/30 13:22:01  RRM
#  --  protect $dd  for Win32 etc. platforms
#
# Revision 1.29  1998/06/18 11:55:12  RRM
#  --  only put the short image-name into ALT text with \htmladdimg
#
# Revision 1.28  1998/05/04 12:02:46  latex2html
#  --  removed the &translate_commands from \htmlref etc.
# 	It is now done by &process_ref in the main script.
#
# Revision 1.27  1998/04/28 13:27:57  latex2html
#  --  small fix to \HTMLset and \HTMLsetenv
#  --  cleaned up the parameter reading of some macros
#  --  {rawhtml} sets a flag, so that entities are preserved
#
# Revision 1.26  1998/02/26 10:21:29  latex2html
#  --  fixed missing $TITLE in \segment
#  --  made the argument-reading more robust
#
# Revision 1.25  1998/01/22 08:24:47  RRM
#  --  put in cosmetic \n
#  --  \htmlmeta defined, for inserting <META...> tags
#
# Revision 1.24  1997/12/16 05:41:02  RRM
#  --  IMG requires an ALT tag in HTML 4
#
# Revision 1.23  1997/12/05 12:53:45  RRM
#  --  cosmetic
#
# Revision 1.22  1997/11/05 10:44:00  RRM
#  --  made some code more robust, concerning section-titles
#
# Revision 1.21  1997/10/20 13:18:07  RRM
#  --  adapted \htmlhead \htmlrule and \htmlrule*
#      to use the new font-state stack, to keep tags correctly nested
#
# Revision 1.20  1997/07/04 13:40:16  RRM
#  -  \htmladdimg now handle image-maps properly, with more flexibility
#
# Revision 1.19  1997/07/03 08:54:12  RRM
#  -  removed redundant 2nd copy of  do_cmd_htmlbody
#  -  revised &do_cmd_htmladdimg  to be consistent with changed code in the
# 	main script; this should also make \htmladdimg more flexible
#
# Revision 1.18  1997/06/13 13:59:20  RRM
#  -   \HTMLset  now has error-checking
#  -   \HTMLsetenv  now actually works !
#
# Revision 1.17  1997/06/06 13:39:37  RRM
#  -  new command:  \htmlborder
#  -  added \HTMLsetenv  as environment-like version of \HTMLset
#  -  updated the message in  \htmlimage  for its extended usage
#  -  simplified the coding for \latex and \latexhtml commands
#
# Revision 1.16  1997/05/19 13:16:35  RRM
#  -  Recognises the AmS-style of delimiter, for conditional environments.
#  -  added some more optional arguments to refs/cites.
#  -  \htmlnohead works *only* in the preamble of segments, by design
#  -  other cosmetic changes.
#
# Revision 1.15  1997/05/09 12:17:16  RRM
#  -  Removed some \n s which were problematic.
#  -  added new command:  \HTMLset  to set Perl variables from within the
#     LaTeX code. e.g. set navigation titles/URLs etc.
#
# Revision 1.14  1997/05/02 04:05:25  RRM
#  -  Allow citations and references to contain macros;
#  -  fixed (?) the problem of figure/table captions from segments
#  -  other small changes
#
# Revision 1.13  1997/04/27 05:43:25  RRM
#      Implemented \htmlcite . Other cosmetic changes.
#
# Revision 1.12  1997/04/14 12:40:16  RRM
#  -  Cosmetic.
#
# Revision 1.11  1997/04/11 14:18:52  RRM
#      Implemented  \latex and improved \latexonly .
#
# Revision 1.10  1997/03/26 09:11:21  RRM
#    Implemented \externalcite and \hypercite interfaces to  &process_cite
#
# Revision 1.9  1997/03/05 00:31:34  RRM
# Added some print messages regarding files required for input.
#
# Revision 1.8  1997/02/17 02:22:54  RRM
# introduced imagesonly environment
#
# Revision 1.7  1997/01/26 08:57:13  RRM
# RRM: added  \htmlbase for setting the <BASE HREF=...> tag.
#      \htmlhead has an optional alignment parameter
#      so does \segment, but it is currently ignored.
#
# Revision 1.6  1996/12/29 23:25:03  L2HADMIN
# some small changes by Ross
#
# Revision 1.5  1996/12/26 19:35:38  JCL
# - \htmladdtonavigation now really adds its contents to the panel
# - introduced \textbackslash
#
# Revision 1.4  1996/12/25 03:01:54  JCL
# introduced usage of &sanitize instead of &encode_title (forgot this here)
# some comments
# \htmlhead should work now with multiple title/section names
#
# Revision 1.3  1996/12/20 05:59:49  JCL
# typo
#
# Revision 1.2  1996/12/20 05:57:49  JCL
# added htmlrule functions
#
# jcl 29-SEP-96 - URL in htmladdimg not reverted to raw TeX.
#   Klaus Steinberger <http://www.bl.physik.tu-muenchen.de/~k2/k2.html>
#   supposed this.
# rrm 25-AUG-96 - Support for segmented documents
# nd  18-AUG-94 - Added do_cmd_htmladdtonavigation
# nd  26-JUL-94 - Moved do_env_latexonly from main script and added support
#                for do_cmd_latexonly
# jz  22-APR-94 - Added command htmlref
# nd  15-APR-94 - Added command htmladdnormallinkfoot
# nd   2-DEC-93 - Created

package main;

# break text, insert rule 
sub do_cmd_htmlrule {
    local($_) = @_;
    local($attribs,$dum)=&get_next_optional_argument;
    local($BRattribs,$HRattribs) = ('','');
    if ($dum) {
        if ($attribs) {
            if (!($attribs =~ /=/)) {
                $BRattribs = &parse_valuesonly($attribs,"BR");
                $HRattribs = &parse_valuesonly($attribs,"HR");
            } else {
                $BRattribs = &parse_keyvalues($attribs,"BR");
                $HRattribs = &parse_keyvalues($attribs,"HR");
            }
        }
    } else { $BRattribs = " CLEAR=\"ALL\"" }    # default if no [...]
    local($pre,$post) = &minimize_open_tags("<BR$BRattribs>\n<HR$HRattribs>");
    join('',$pre,$_);
#    join('',"<BR$BRattribs>\n<HR$HRattribs>",$_);
}


# insert rule but omit the <BR> tag.
sub do_cmd_htmlrulestar {
    local($_) = @_;
    local($attribs,$dum)=&get_next_optional_argument;
    local($HRattribs) = ('');
    if ($dum) {
        if ($attribs) {
            if (!($attribs =~ /=/)) {
                $HRattribs = &parse_valuesonly($attribs,"HR");
            } else {
                $HRattribs = &parse_keyvalues($attribs,"HR");
            }
        }
    } else { }  # default if no [...]
    local($pre,$post) = &minimize_open_tags("<HR$HRattribs>");
    join('',$pre,$_);
}

sub do_cmd_htmladdnormallink{
    local($_) = @_;
    local($text, $url, $href);
    local($name, $dummy) = &get_next_optional_argument;
    s/$next_pair_pr_rx/$text = $2; ''/eo;
    s/$next_pair_pr_rx/$url = $2; ''/eo;
    $*=1; s/^\s+/\n/; $*=0;
    if ($name) { $href = &make_named_href($name,$url,$text) }
    else { $href = &make_href($url,$text) }
    print "\nHREF:$href" if ($VERBOSITY > 3);
    join ('',$href,$_);
}

sub do_cmd_htmladdnormallinkfoot{
    &do_cmd_htmladdnormallink(@_);
}

sub do_cmd_htmladdimg{
    local($_) = @_;
    local($name,$url,$align,$alt,$map)=("external",'','','','');
    local($opts, $dummy) = &get_next_optional_argument;
    $opts = &revert_to_raw_tex($opts);
    $opts =~ s/(^\s*|\s+)(left|right|center)(\s+|\s*$)/$align=$1;''/ioe if ($opts);
    $opts =~ s/\s*ALIGN=\"([^\"]+)\"\s*/$align=$1;''/ioe if ($opts);
    $opts =~ s/\s*NAME=\"([^\"]+)\"\s*/$name=$1;''/ioe if ($opts);
    $opts =~ s/\s*ALT=\"([^\"]+)\"\s*/$alt=$1;''/ioe if ($opts);
    $opts =~ s/\s*ISMAP\s*/$map=$1;''/ioe if ($opts);
    s/$next_pair_pr_rx/$url = $2; ''/eo;
    if (!$alt) {
#    	$url=~ /$dd([^$dd$dd]+)$/;
	$url =~ m@/([^/]+)$@;
	$alt = $1;
    	$alt = $url unless $alt;
    }
    $url = &revert_to_raw_tex($url);
    join('',&embed_image($url,$name,'',$alt,'',$map,$align
		,'','',$opts),$_);
}

sub do_cmd_externallabels{
    local($_) = @_;
    local($URL,$labelfile);
    s/$next_pair_pr_rx/$URL = $2; ''/eo;
    s/$next_pair_pr_rx/$labelfile = $2; ''/eo;
#
    local($dir,$nosave) = ('','');
#
    if (-f "$labelfile") {
	print "\nLoading label data from file: $labelfile\n";
	require($labelfile);
    } else {
	&write_warnings(
	    "Could not find the external label file: $labelfile\n");
    }
    $_;
}

# This command is passed via the .ptr files to LaTeX2HTML.
# It helps to build the document title of a segment.
sub do_cmd_htmlhead {
    local($_) = @_;
    local(@tmp, $section_number, $sec_id, $hash, $align, $dummy);
    ($align, $dummy) = &get_next_optional_argument;
    if ($align =~/(left|right|center)/i) { $align = "ALIGN=\"$1\""; }
    local($curr_sec, $title);
    $curr_sec = &missing_braces unless (
	(s/$next_pair_pr_rx/$curr_sec = $2;''/e)
	||(s/$next_pair_rx/$curr_sec = $2;''/e));
    $curr_sec =~ s/\*$/star/;
    $current_depth = $section_commands{$curr_sec};
    $title = &missing_braces unless (
	(s/$next_pair_pr_rx/$title = $2;''/e)
	||(s/$next_pair_rx/$title = $2;''/e));
#JCL - use &sanitize
    $hash = &sanitize($title);
    # This is the LaTeX section number read from the $FILE.aux file
    @tmp = split(/$;/,$encoded_section_number{$hash});
    $section_number = shift(@tmp);
    $section_number = "" if ($section_number eq "-1");
    $title = "$section_number " . $title if $section_number;
    $TITLE = $title unless ($TITLE);

    # record it in encoded form, when it starts a segment
    if (($SEGMENT)&&($PREAMBLE)) {
	$TITLE = $title;
	$encoded_section_number{$hash} = join($;, @tmp);
	@tmp = @curr_sec_id;
#	$tmp[$current_depth] = 0;
	$toc_section_info{join(' ', @tmp)} =
	    "$current_depth$delim$CURRENT_FILE$delim$TITLE";
    }
    local($this_head) = &make_section_heading($title, "H2", $align);
    local($pre,$post) = &minimize_open_tags("<P>$this_head");
    join('',$pre,$_);
}

sub do_cmd_htmlnohead {
    local($_) = @_;
    ${AtBeginDocument_hook} .= " eval {\$_ = \"\";};"
	if (($SEGMENT)&&($PREAMBLE));
    $_;
}

sub do_cmd_segment {
    local($_) = @_;
    local($ctr, $index, $ditch);
    &get_next_optional_argument;# heading alignment, ignored
    $ditch = &missing_braces unless (# Ditch filename
	(s/$next_pair_pr_rx//o)||(s/$next_pair_rx//o));
    $ctr = &missing_braces unless (
	(s/$next_pair_pr_rx/$ctr = $2;''/eo)
	||(s/$next_pair_rx/$ctr = $2;''/eo));
    $ditch = &missing_braces unless (# Ditch title
	(s/$next_pair_pr_rx//o)||(s/$next_pair_rx//o));
#    s/$next_pair_pr_rx//o;
    $segment_sec_id[$index] += 1 if ($index = $section_commands{$ctr});
    $SEGMENTED = 1;
    $_;
}

sub do_cmd_segmentstar {
    local($_) = @_;
    $_ = &do_cmd_segment($_);
    $_;
}

sub do_cmd_htmlbase {
    local($_) = @_;
    s/$next_pair_pr_rx/$BASE = &revert_to_raw_tex($2);''/e;
    $_;
}

sub do_cmd_htmlmeta {
    local($_) = @_;
    s/$next_pair_pr_rx/$HTML_META .= join('',&revert_to_raw_tex($2),"\n");''/e;
    $_;
}

sub do_cmd_bodytext {
    local($_) = @_;
    s/$next_pair_pr_rx//o; $BODYTEXT = &revert_to_raw_tex($2);
    $_;
}

sub do_cmd_htmlbody {
    local($_) = @_;
    local($attribs,$dum)=&get_next_optional_argument;
    local($BODYattribs) = ('');
    if ($dum) {
	if ($attribs) {
	    if (!($attribs =~ /=/)) {
		$BODYattribs = &parse_valuesonly($attribs,"BODY");
	    } else {
		$BODYattribs = &parse_keyvalues($attribs,"BODY");
	    }
	}
    } else { }	# default if no [...]
    $BODYTEXT .= $BODYattribs;
    $_;
}

sub do_cmd_internal{
    local($_) = @_;
    local($type, $prefix, $file, $var, $buf);
    $type = "internals";
    s/$optional_arg_rx/$type = $1; ''/eo;
    s/$next_pair_pr_rx/$prefix = $2; ''/eo;
    $file = "${prefix}$type.pl";
    unless (-f $file) {
	print "\nCould not find file: $file \n";
	return ($_);
    }
    local($dir,$nosave) = ('',1); 
    local($tmpdir,$rest) = ('',''); 
    if ($MULTIPLE_FILES && $ROOTED) {
	$nosave = '';
    } else {
	($tmpdir, $rest) = split(/\Q$dd\E/, $file, 2); 
	while ($rest) {
	    $dir .= $tmpdir . $dd;
	    ($tmpdir, $rest) =  split(/\Q$dd\E/, $rest, 2);
	}
    }

    if (!($type =~ /(figure|table)/)) {
	print "Loading segment data from $file \n" if ($DEBUG||$VERBOSITY);
	require ($file);
	return ($_);
    }

    # figure/table captions
    local($after,$this) = ($_,'');
    open (CAPTIONS, $file);
    while (<CAPTIONS>) {
	if (/^'/) { $this = $_ }
	else { $this .= $_ }
	if ($this =~ /'$/) {
	    eval "\$buf = ".$this;
	    $this = "\n";
	}
    }
#    $buf = join('', <CAPTIONS>);
    if ($type =~ /figure/ ) {
	if (defined $segment_figure_captions) { 
	    $segment_figure_captions .= (($segment_figure_captions)? "\n" : '') . $buf
	} else {
	    $segment_figure_captions = $figure_captions
		. (($figure_captions)? "\n" : '') . $buf
	}
    } else {
	if (defined $segment_table_captions) {
	    $segment_table_captions .= (($segment_table_captions)? "\n" : '') . $buf
	} else { 
	    $segment_table_captions = $table_captions
	        . (($table_captions)? "\n" : '') .  $buf
	}
    }
    close (CAPTIONS);
    $after;
}
	
sub do_cmd_externalref {
    local($_) = @_;
    &process_ref($external_ref_mark,$external_ref_mark);
}

sub do_cmd_externalcite {
    local($_) = @_;
    &process_cite("external",'');
}

sub do_cmd_hyperref {
    local($_) = @_;
    local($text);
    local($opt, $dummy) = &get_next_optional_argument;
    s/$next_pair_pr_rx/$text = $2; ''/eo;
    s/$next_pair_pr_rx//o; # Throw this away ...
    s/$next_pair_pr_rx//o unless ($opt =~ /no/);
    &process_ref($cross_ref_mark,$cross_ref_mark,$text);
}

sub do_cmd_hypercite {
    local($_) = @_;
    local($text);
    local($opt, $dummy) = &get_next_optional_argument;
    $opt = (($opt =~ /ext|no/) ? "external" : '' );
    s/$next_pair_pr_rx/$text = $2; ''/eo;
    s/$next_pair_pr_rx//o;                # Throw this away ...
    s/$next_pair_pr_rx//o unless ($opt);  # ... and this too.
    &process_cite($opt, $text);
}

sub do_cmd_htmlref {
    local($_) = @_;
    local($text);
    local($opt, $dummy) = &get_next_optional_argument;
    s/$next_pair_pr_rx/$text = $2; ''/eo;
    &process_ref($cross_ref_mark,$cross_ref_mark,$text);
}

sub do_cmd_htmlcite {
    local($_) = @_;
    local($text);
    local($opt, $dummy) = &get_next_optional_argument;
    $opt = (($opt =~ /ext/) ? "external" : '' );
    s/$next_pair_pr_rx/$text = $2; ''/eo;
    &process_cite($opt,$text);
}


# IGNORE the contents of this environment 
sub do_env_latexonly {
    "";
}

# use the contents of this environment only in images.tex 
sub do_env_imagesonly {
    local($_) = @_;
    if ($PREAMBLE) { $preamble .= &revert_to_raw_tex($_)}
    else { $latex_body .=  "\n".&revert_to_raw_tex($_)}
    $contents = '';
    '';
}

# IGNORE the argument of this command (declaration below)
#sub do_cmd_latex {
#    local($this) = &do_cmd_latexonly($_);
#}

# IGNORE the argument of this command
sub do_cmd_htmlimage {
    local($_) = @_;
    local($attribs);
    s/$next_pair_pr_rx/$attribs=$2;''/eo;
    &write_warnings(
	"\nThe command \"\\htmlimage\" is only effective inside an environment\n"
	. "which may generate an image (eg \"{figure}\", \"{equation}\")\n"
	. " $env$id: \\htmlimage{$attribs}");
    print STDERR
	"\nThe command \"\\htmlimage\" is only effective inside an environment\n"
	. "which may generate an image (eg \"{figure}\", \"{equation}\")\n"
	. " $env$id: \\htmlimage{$attribs}" if ($VERBOSITY > 1);
    $_;
}

# IGNORE the argument of this command
sub do_cmd_htmlborder {
    local($_) = @_;
    &get_next_optional_argument;
    s/$next_pair_pr_rx//o;
    &write_warnings(
	"\nThe command \"htmlborder\" is only effective inside an " .
	"environment which uses a <TABLE> (eg \"{figure}\")\n");
    print STDERR
	"\nThe command \"htmlborder\" is only effective inside an " .
	"environment which uses a <TABLE> (eg \"{figure}\")\n"
	if ($VERBOSITY > 1);
    $_;
}

sub do_cmd_htmladdtonavigation {
    local($_) = @_;
    s/$next_pair_pr_rx//o;
    $CUSTOM_BUTTONS .= $2;
    $_;
}

sub do_cmd_HTMLset {
    local($_) = @_;
    local($which,$value,$hash,$dummy);
    local($hash, $dummy) = &get_next_optional_argument;
    $which = &missing_braces unless (
	(s/$next_pair_pr_rx/$which = $2;''/eo)
	||(s/$next_pair_rx/$which = $2;''/eo));
    $value = &missing_braces unless (
	(s/$next_pair_pr_rx/$value = $2;''/eo)
	||(s/$next_pair_rx/$value = $2;''/eo));
    if ($hash) {
	local($tmp) = "\%$hash";
	if (eval "defined \%{$hash}") { $! = '';
#	    eval "\$$hash{'$which'} = \"$value\";";
	    ${$hash}{'$which'} = $value;
	    print "\nHTMLset failed: $! " if ($!);
	} else { print "\nhash: \%$hash not defined" }
    } elsif ($which) { $! = '';
	eval "\${$which} = \"$value\";";
	print "\nHTMLset failed: $! " if ($!);
    }
    $_;
}

# this has been wrapped, so doesn't need to return anything.
sub do_cmd_HTMLsetenv { &do_cmd_HTMLset;}



&process_commands_wrap_deferred (<<_RAW_ARG_DEFERRED_CMDS_);
comment # <<\\endcomment>>
htmlonly # <<\\endhtmlonly>>
latexonly # <<\\endlatexonly>>
imagesonly # <<\\endimagesonly>>
rawhtml # <<\\endrawhtml>>
htmlhead # [] # {} # {}
htmlrule # [] 
htmlrulestar # [] 
_RAW_ARG_DEFERRED_CMDS_


&ignore_commands( <<_IGNORED_CMDS_);
comment # <<\\endcomment>>
latex # {}
latexhtml # {}
htmlonly
endhtmlonly
latexonly # <<\\endlatexonly>>
imagesonly # <<\\endimagesonly>>  &do_env_imagesonly(\$args)
rawhtml # <<\\endrawhtml>> local(\$env)='rawhtml';\$_ = join('',&revert_to_raw_tex(\$args),\$_)
_IGNORED_CMDS_

1;				# This must be the last line











