//-----------------------------------------------------------------------------
//    mwForum - Web-based discussion forum
//    Copyright (c) 1999-2011 Markus Wichitill
//
//    Quickreply
//    Copyright (c) 2008-2011 Tobias Jaeggi
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//-----------------------------------------------------------------------------

var qe = {};

$(document).ready(function () {
	// No post is currently edited.
	qe.currId = -1;
	// Are we loading data right now?
	qe.currLoading = false;
	// Offset
	qe.currOffset = 0;
	
	// We want. more moneh.
	mwf.initTagButtons();
	
	// show the quickedit buttons
	$('a.qe').show();
});

$(document).ajaxError(function(event, jqXHR, ajaxSettings, thrownError) {
	// If we aren't loading, we don't care.
	if (!qe.currLoading)
		return;
	// We aren't loading anymore!
	qe.currLoading = false;
	qe.loadQuickEdit(-1);
	$('a.qe').hide();
	// Not translated, but this shouldn't happen anyway.
	alert('Quickedit is not available at the moment (' + thrownError + ').');
});

qe.loadQuickEdit = function(postId) {
	// Same or loading in progress?
	if (postId == qe.currId || qe.currLoading)
		return;
	
	// Restore the old box.
	if (qe.currId != -1) {
		var post = $('#pid' + qe.currId + ' > .ccl:first');
		post.show();
	}
	
	qe.currId = postId;
	
	// Is the new id -1?
	if (postId == -1) {
		// hide the box.
		$('#qe').hide();
		return;
	}
	
	qe.currLoading = true;
	
	// Save the offset
	qe.currOffset = $(document).scrollTop();
	
	// Move the box. Muchos <3 for jquery
	$('#pid' + postId + ' > .ccl:first').after($('#qewait').show()).hide();
	
	$(document).scrollTop(qe.currOffset)
	
	// Send the AJAX request.
	$.post('ajax_quickedit' + mwf.p.m_ext, { pid: postId }, qe.receivedResponse);
}

qe.receivedResponse = function(json) {
	if (json.error) {
		$.error('Invalid post.');
	}
	
	// Move our box.
	$('#qewait').after($('#qe').show()).hide();
	$('#qebody').html(json.body.replace(/\\n/g, "\n")).focus();
	$('#qepid').val(qe.currId);
	$('#qeraw').val((json.raw || '').replace(/\\n/g, "\n"));
	$('#qesubject').val(json.subject || '');
	qe.currLoading = false;
	
	// Move the scroll
	$(document).scrollTop(qe.currOffset)
}