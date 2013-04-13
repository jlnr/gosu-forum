#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2008 Markus Wichitill
#
#    MwfPlgAutoTimeout- does what forum.pl does, for stupids.
#    Copyright (c) 2010 Tobias Jaeggi
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

package MwfPlgAutoTimeout;
use strict;
use warnings;
no warnings qw(uninitialized redefine);
our $VERSION = "2.20.0";

#-----------------------------------------------------------------------------

sub event {
	my %params = @_;
	my $m = $params{m};
	my $user = $m->{user};
	
	if ($user->{id}) {
		my $prevOnCookie = $m->getCookie('prevon');
		my $prevOnTime = $m->max($prevOnCookie, $user->{lastOnTime}) || $m->{now};
		return if ($prevOnTime - $user->{lastOnTime} < 3600);
		$m->{userUpdates}{prevOnTime} = $prevOnTime;
		$m->setCookie('prevon', $prevOnTime);
	}	
}

#-----------------------------------------------------------------------------
1;
