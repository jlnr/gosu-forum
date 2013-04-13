#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2011 Markus Wichitill
#
#    Quickedit-Addon
#    Copyright (c) 2011 Tobias Jaeggi
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#------------------------------------------------------------------------------

package MwfPlgQuickedit;
use strict;
use warnings;
#~ no warnings qw(uninitialized redefine once);
our $VERSION = "2.24.0";

#-----------------------------------------------------------------------------
# Add quickedit.js.
sub htmlHeader {
	my %params = @_;
	my $m = $params{m};
	return unless $m->{env}{script} eq "topic_show";
	print "<script type='text/javascript' src='$m->{cfg}{dataPath}/quickedit.js'></script>\n";
}

#-----------------------------------------------------------------------------
# Print button link for a post on the topic page
# Works a bit differently than the other button link include interfaces.

sub postLink
{
	my %params = @_;
	my $m = $params{m};
  my $lng = $m->{lng};
	my $lines = $params{lines};
	my $board = $params{board};
	my $topic = $params{topic};
	my $post = $params{post};
	my $boardAdmin = $params{boardAdmin};
  my $topicAdmin = $params{topicAdmin};
  my $postUserId = $post->{userId};
  
	# Language Things, here done.
	if (!exists($lng->{qeClose})) {
		if ($m->{lngModule} eq 'MwfGerman') {
			$lng->{qeCancel}      = 'Abbrechen';
			$lng->{qeButtonTtl}  = 'Schnellbearbeitung';
			$lng->{qeButtonTT} = 'Schnellbearbeitung';
			$lng->{qeLoading} = 'Lade...';
		} 
		else {
			$lng->{qeCancel}      = 'Cancel';
			$lng->{qeButtonTtl}  = 'Quickedit';
			$lng->{qeButtonTT} = 'Quickedit';
			$lng->{qeLoading} = 'Loading...';
		}
	}
	
	# Check if we are allowed to answer to this post
	if ($m->{user}{id}
				&& ($m->{user}{id} == $postUserId && !$topic->{locked} 
				&& !$post->{locked} || $boardAdmin || $topicAdmin)
				&& !($postUserId == -2 && $post->{id} != $topic->{basePostId}))
	{
    my $url = $m->url('post_edit', pid => $post->{id});
		
		# Search the 'edit' button.
		my $index = 0;
		
		for (my $i = 0; $i < $#$lines; ++$i) {
			if ($lines->[$i] =~ /post_edit/o) {
				$index = $i;
				last;
			}
		}
		
		# And add it right in front of it
    splice @$lines, $index, 0, "<a class='qe' onclick='qe.loadQuickEdit($post->{id})' style='cursor:pointer;display:none;' title='$lng->{qeButtonTT}'>",
      $m->{buttonIcons} ? "<img class='bic bic_edit' src='$m->{cfg}{dataPath}/epx.png' alt=''/> " : "",
      "$lng->{qeButtonTtl}</a>\n";
  }
}


#------------------------------------------------------------------------------
# Print stuff at the bottom of the page

sub bottom
{
	my %params = @_;
	my $m = $params{m};
	my $cfg = $m->{cfg};
  return unless $m->{env}{script} eq "topic_show";
  my $user = $m->{user};
  my $lng = $m->{lng};
  my $stylePath = $m->{cfg}{dataPath} . '/' . $m->{style};
	my $showTags = exists($cfg->{qeTags}) && $cfg->{qeTags};
	# Disabled, as of now.
	#~ my $showPreviewButton = exists($cfg->{qePreview}) && $cfg->{qePreview};
	
	# Print the "PLEASE WAIT" box.
	print
		"<div id='qewait' class='ccl' style='display:none'>\n",
		"$lng->{qeLoading}\n",
		"</div>\n";
	
  # Print the quick edit box
  print 
    "<div id='qe' class='ccl' style='display:none;'>\n";
		#~ "<div id='qe' class='ccl'>\n";

  # form
  print
    "<form action='post_edit$m->{ext}' method='post'>\n",
    $showTags 
		 ? $m->tagButtons() : "",
    "<textarea name='body' class='tgi' cols='80' rows='4' id='qebody'></textarea><br/>\n",
    $m->submitButton('eptEditB', 'edit'),
		#~ $showPreviewButton
		 #~ ? $m->submitButton('rplReplyPrvB', 'preview', 'preview') : "",
    "<input type='hidden' name='pid' id='qepid' value='0'/>\n",
		"<input type='hidden' name='subject' id='qesubject' value=''/>\n",
		"<input type='hidden' name='edit' value='edit'/>\n",
		"<textarea name='raw' id='qeraw' value='' style='display:none'></textarea>\n",
		"<button type='button' class='isb' onclick='qe.loadQuickEdit(-1)'>",
		$m->{buttonIcons} 
			? "<img class='bic bic_remove' src='$cfg->{dataPath}/epx.png' alt=''/> " : "",
    "$lng->{qeCancel}</button>\n",
    $m->stdFormFields(),
    "</div>\n",
    "</form>\n",	
    "</div>\n\n";
}