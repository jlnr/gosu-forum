#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2011 Markus Wichitill
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

package MwfPlgCodeBackticks;
use strict;
use warnings;
no warnings qw(uninitialized redefine);
our $VERSION = "2.23.0";

#------------------------------------------------------------------------------
# Replace text with image smileys

sub smileys
{
	my %params = @_;
	my $m = $params{m};
	my $board = $params{board};
	my $post = $params{post};

	# Replace code blocks
	my $text = \$post->{body};
	$$text =~ s!`(.+?)`!<code>$1</code>!g;

	return 0;
}

#------------------------------------------------------------------------------
1;
