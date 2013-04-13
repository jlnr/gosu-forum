#!/usr/bin/perl
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

use strict;
use warnings;
no warnings qw(uninitialized redefine);

# Imports
use MwfMain;

#------------------------------------------------------------------------------

# Init
my ($m, $cfg, $lng, $user, $userId) = MwfMain->new($_[0], ajax => 1);

$m->printHttpHeader();

# Copy: post_edit.pl
my $postId = $m->paramInt('pid');
$postId or $m->error('errParamMiss');

# Get post
my $post = $m->fetchHash("
	SELECT * FROM posts WHERE id = ?", $postId);
$post or $m->error('errPstNotFnd');
my $boardId = $post->{boardId};
my $topicId = $post->{topicId};

# Get board
my $board = $m->fetchHash("
	SELECT * FROM boards WHERE id = ?", $boardId);
$board or $m->error('errBrdNotFnd');

# Get topic
my $topic = $m->fetchHash("
	SELECT * FROM topics WHERE id = ?", $topicId);
$topic or $m->error('errTpcNotFnd');

# Check if user can see and write to board
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $boardId) 
	|| $board->{topicAdmins} && $m->topicAdmin($userId, $topicId);
my $boardMember = $m->boardMember($userId, $boardId);
$boardAdmin || $boardMember || $m->boardVisible($board) or $m->error('errNoAccess');
$boardAdmin || $boardMember || $m->boardWritable($board, 1) or $m->error('errNoAccess');

# Check if user owns post or is moderator
$userId && $userId == $post->{userId} || $boardAdmin or $m->error('errNoAccess');

# Don't allow editing of approved posts in moderated boards
!$board->{approve} || !$post->{approved} || $boardAdmin || ($boardMember && $board->{private} != 1)
	or $m->error('errEditAppr');

# Check editing time limitation
!$cfg->{postEditTime} || $m->{now} < $post->{postTime} + $cfg->{postEditTime} 
	|| $boardAdmin || $boardMember
	or $m->error('errPstEdtTme');

# Check if topic or post is locked
!$topic->{locked} || $boardAdmin or $m->error('errTpcLocked');
!$post->{locked} || $boardAdmin or $m->error('errPstLocked');

# Check authorization
$m->checkAuthz($user, 'editPost');

# /copy.

# Translate the posting
$m->dbToEdit($board, $post);

$post->{body} =~ s![\n\r]!\\n!g;
$post->{rawBody} =~ s[\n\r]!\\n!g;

# Prepare the response
my %response = (body => $post->{body});

# Subject?
$response{subject} = $m->deescHtml($topic->{subject}) if $postId == $topic->{basePostId};

# Raw?
$response{raw} = $post->{rawBody} if $post->{rawBody} ne '';

# Send it
print $m->json(\%response);

# Done.
$m->finish();
