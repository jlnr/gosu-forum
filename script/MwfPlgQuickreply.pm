#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2010 Markus Wichitill
#
#    Quickreply-Addon
#    Copyright (c) 2008-2010 Tobias Jaeggi
#    Copyright (c) 2006 Tobias Zwick
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

package MwfPlgQuickreply;
use strict;
use warnings;
no warnings qw(uninitialized redefine once);
our $VERSION = "2.20.0";

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
	my $showCaptcha = $cfg->{captcha} && exists($cfg->{qrCaptcha}) && $cfg->{qrCaptcha};
	my $showTags = exists($cfg->{qrTags}) && $cfg->{qrTags};
	my $showPreviewButton = exists($cfg->{qrPreview}) && $cfg->{qrPreview};
	# Because we can't access $board here, we just "assume" it allows to write stuff.
	my $showUnregName = exists($cfg->{qrUnregName}) && $cfg->{qrUnregName} && $cfg->{allowUnregName} && !$user->{id};
	
	# CAPTCHAS!
	require MwfCaptcha if $showCaptcha;
	
  print <<"EOSCRIPT";
<script type='text/javascript'>$m->{cdataStart}
	var indent = $user->{indent};
$m->{cdataEnd}</script>\n
EOSCRIPT
;

  # Print the quick reply box
  print 
    "<div id='qr' class='frm pst new' style='display:none;'>\n",
    "<div class='hcl'>\n",
     "<span class='nav'>\n";
  
  # Print close and up button
  print
    "<a href='' id='qrparent'><img class='sic sic_nav_up' src='$m->{cfg}{dataPath}/epx.png'",
    " title='$lng->{tpcParentTT}' alt='$lng->{tpcParent}'/></a>\n",
    "<img style='vertical-align:text-top;width:16px;height:16px;' id='qrCloseQuickReply' src='$stylePath/nav_close.png'",
    " title='$lng->{qrClose}' alt='X'/>\n",
    "</span>\n";
  
  # title
  print
    "<span class='htt'>$lng->{qrTitleBar}</span>\n",
    "<span id='qrname'>?</span>",
    "</div>\n";
  
	# Print username input for geust posts
	print
		"$lng->{rplReplyName}<br/>\n",
		"<input type='text' name='name' size='40' maxlength='$cfg->{maxUserNameLen}'",
		" value=''/><br/><br/>\n"
		if $showUnregName;

  # form
  print
    "<form action='post_add$m->{ext}' method='post'>\n",
    "<div class='ccl'>\n",
    $showTags 
		 ? $m->tagButtons() : "",
    "<textarea name='body' cols='80' rows='4' id='qrtextarea'></textarea><br/>\n",
		$showCaptcha && ($cfg->{captcha} >= 3 || $cfg->{captcha} >= 2 && !$m->{user}{id})
		 ? MwfCaptcha::captchaInputs($m, 'pstCpt') : "",
    $m->submitButton('rplReplyB', 'write', 'add'),
		$showPreviewButton
		 ? $m->submitButton('rplReplyPrvB', 'preview', 'preview') : "",
    "<input type='hidden' name='pid' id='qrpid' value='0'/>\n",
    $m->stdFormFields(),
    "</div>\n",
    "</form>\n",	
    "</div>\n\n";
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
	if (!exists($lng->{qrClose})) {
		if ($m->{lngModule} eq 'MwfGerman') {
			$lng->{qrClose}      = "Schliessen";
			$lng->{qrButtonTtl}  = "Schnellantwort";
			$lng->{qrButtonTT}   = "Schnell antworten";
			$lng->{qrTitleBar}   = "Antwort auf Nachricht von";
		} 
		else {
			$lng->{qrClose}      = "Close";
			$lng->{qrButtonTtl}  = "Quickreply";
			$lng->{qrButtonTT}   = "Quick reply";
			$lng->{qrTitleBar}   = "In Response to";			
		}
	}
	
	# Check if we are allowed to answer to this post
  if ((!$topic->{locked} && !$post->{locked} && $m->boardWritable($board, 1) || $boardAdmin || $topicAdmin) 
    && ($post->{userId} != -2 || $post->{id} == $topic->{basePostId})) {
    my $url = $m->url('post_add', pid => $post->{id});
    #~ push @btlLines, $m->buttonLink($url, 'tpcReply', 'write');
    my $qruserName = $post->{userName} || $post->{userNameBak} || " - ";
    unshift @$lines, "<a class='btl qr' onclick='qr.openQuickReply($post->{id})' style='cursor:pointer;display:none;' title='$lng->{qrButtonTT}'>",
      $m->{buttonIcons} ? "<img class='bic bic_write' src='$m->{cfg}{dataPath}/epx.png' alt=''/> " : "",
      "$lng->{qrButtonTtl}</a>\n",
      "<span id='qrnfield$post->{id}' style='display:none;'>$qruserName</span>";
  }
}

#-----------------------------------------------------------------------------
# Add qr.js.
sub htmlHeader {
	my %params = @_;
	my $m = $params{m};
	return unless $m->{env}{script} eq "topic_show";
	print "<script type='text/javascript' src='$m->{cfg}{dataPath}/quickreply.js'></script>\n";
}
#-----------------------------------------------------------------------------
1;
