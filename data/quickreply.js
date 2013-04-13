//-----------------------------------------------------------------------------
//    mwForum - Web-based discussion forum
//    Copyright (c) 1999-2009 Markus Wichitill
//
//    Quickreply
//    Copyright (c) 2008-2010 Tobias Jaeggi
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

var qr = {};

qr.onLoad = function() {
	// show the quickreply buttons
	qr.currId = -1;
	var qrbtns = document.getElementsByTagName("a");
	for (var i = 0; i < qrbtns.length;  i++) {
		if (qrbtns[i].className.indexOf('qr') != -1) {
			qrbtns[i].style.display = '';
		}
	}
};

if (window.addEventListener) { window.addEventListener('load', qr.onLoad, false); }
else if (window.attachEvent) { window.attachEvent('onload', qr.onLoad); }

qr.hideChildBranches = function (postId) {
	var branch = document.getElementById('brn'+postId);
	var divs = branch.getElementsByTagName('div');
	for (var i = 0; i < divs.length; i++) {
		if (divs[i].id.indexOf('brn') == 0)
		  if (divs[i].style.display == '')
			  qr.toggleBranch(divs[i].id.substr(3));
	}
};

qr.createBranch = function(postId) {
	var branch = document.createElement('div');
	var post = document.getElementById('pid'+postId);
		
	branch.id = 'brn'+postId;
		
	// if not first post: just append
	if (post.parentNode != document.body) {
		post.parentNode.insertBefore(branch, post.nextSibling);
	} else { // first post: create branch at right position
		// search all divs for the post
		var divs = document.body.childNodes;
		for (var i = 0; divs[i]; ++i) {
			if (divs[i] == post)
				break;
		}
		// then insert before the element after it (*cough*)
		document.body.insertBefore(branch, divs[i+1]);
	}
	return branch;
};

qr.openQuickReply = function(postId) {
	var box = document.getElementById('qr');
	if (!box) return;
		
	// delete (make invisible)
	if (postId == -1) {
		box.style.display = 'none';
		qr.currId = -1;
		return;
	}
	
	var branch = document.getElementById('brn'+postId);
		
	// not same reply
	if (qr.currId != postId) {
		// copy
		var reply = box.cloneNode(true);
		
		// gather information
		var post = document.getElementById('pid'+postId);
			
		var postindentp = post.style.marginLeft;
		var postindent = postindentp.substr(0, postindentp.length-1);
			
		// set reply's properties
		reply.style.display = '';
		reply.style.marginLeft = 1*postindent+indent+'%';
			
		// display
			
		// no branch yet? No problem, create one
		if (!branch) branch = qr.createBranch(postId);
		branch.appendChild(reply);
		qr.currId = postId;
			
		// delete the old
		box.parentNode.removeChild(box);
		box = reply;
			
		// close button
		var close = document.getElementById('qrCloseQuickReply');
		close.onclick = qr.closeQuickReply;
			
		// up button
		var up = document.getElementById('qrparent');
		up.href = '#pid'+postId;
			
		// name of the parent poster
		var qrnfield = document.getElementById('qrnfield'+postId);
			
		// print name
		var name = document.getElementById('qrname');
		name.firstChild.nodeValue = qrnfield.firstChild.nodeValue;
			
		// post id for posting
		var pid = document.getElementById('qrpid');
		pid.value = postId;
	}
		
	// toggle the branch if necessary
	if (branch.style.display == 'none')
		qr.toggleBranch(postId);
		
	// hide all childs of the branch
	qr.hideChildBranches(postId);
		
	// Thank you, CRAP JAVASCRIPT IMPLEMENTATION NOT ALLOWING ME TO CLONE EVENTS.
	qr.initTagButtons();	
	
	// focus it!
	document.getElementById('qrtextarea').focus();
		
	// in order to get the "write" button in view
	window.scrollBy(0, 35);		
};

qr.closeQuickReply = function() { qr.openQuickReply(-1); };

qr.insertTags = function(tag1, tag2) {
	var txta = document.getElementById('qrtextarea');
	txta.focus();
	if (document.selection) {
		var range = document.selection.createRange();
		var sel = range.text;
		range.text = tag2
			? "[" + tag1 + "]" + sel + "[/" + tag2 + "]"
			: ":" + tag1 + ":";
		range = document.selection.createRange();
		if (tag2 && !sel.length) range.move('character', -tag2.length - 3);
		else if (tag2) range.move('character', tag1.length + 2 + sel.length + tag2.length + 3);
		range.select();
	}
	else if (typeof txta.selectionStart != 'undefined') {
		var scroll = txta.scrollTop;
		var start  = txta.selectionStart;
		var end    = txta.selectionEnd;
		var before = txta.value.substring(0, start);
		var sel    = txta.value.substring(start, end);
		var after  = txta.value.substring(end, txta.textLength);
		txta.value = tag2
			? before + "[" + tag1 + "]" + sel + "[/" + tag2 + "]" + after
			: before + ":" + tag1 + ":" + after;
		var caret = sel.length == 0
			? start + tag1.length + 2
			: start + tag1.length + 2 + sel.length + tag2.length + 3;
		txta.selectionStart = caret;
		txta.selectionEnd = caret;
		txta.scrollTop = scroll;
	}
};

qr.initTagButtons = function() {
	var elems = getElementsByClassName('tbt');
	for (var i = 0; i < elems.length; i++) { (function(i) {
		var elem = elems[i];
		var match = elem.id.match(/tbt_([a-z]+)/)
		var tag1 = match[1];
		var tag2 = tag1;
		if (elem.className.match(/\btbt_p\b/)) tag1 += "=";
		match = elem.id.match(/\btbt_[a-z]+_([a-z]+)/);
		if (match) tag1 += "=" + match[1];
		elem.onclick = function() { qr.insertTags(tag1, tag2) };
		elem.onfocus = function() { document.getElementById('qrtextarea').focus() };
	})(i) }
	elems = getElementsByClassName('tbc');
	for (var i = 0; i < elems.length; i++) { (function(i) {
		var elem = elems[i];
		var tag = elem.id.substr(4);
		elem.onclick = function() { qr.insertTags(tag) };
	})(i) }
};

//-----------------------------------------------------------------------------

qr.scrollToPost = function(postId) {
	var elem = document.getElementById('pid' + postId);
	if (elem) window.scrollTo(0, elem.offsetTop - 5);
};

//-----------------------------------------------------------------------------

qr.toggleBranch = function(postId) {
	// assuming mwf can do that for us. Because otherwise, I even have to mess around
	// with language strings. And if this point is reached, I stop developing this stupid plugin.
	mwf.toggleBranch(postId);
};

//-----------------------------------------------------------------------------
// Derived from: getElementsByClassName (c) 2008 Robert Nyman, http://www.robertnyman.com
// Code/licensing: http://code.google.com/p/getelementsbyclassname/
//
// Guess why this is here.

var getElementsByClassName = function (className, tag, el) {
	if (document.getElementsByClassName) {
		getElementsByClassName = function (className, tag, el) {
			el = el || document;
			var elements = el.getElementsByClassName(className),
				nodeName = tag ? new RegExp("\\b" + tag + "\\b", "i") : null,
				returnElements = [],
				current;
			for (var i = 0, il = elements.length; i < il; i += 1) {
				current = elements[i];
				if (!nodeName || nodeName.test(current.nodeName)) {
					returnElements.push(current);
				}
			}
			return returnElements;
		};
	}
	else {
		getElementsByClassName = function (className, tag, el) {
			tag = tag || "*";
			el = el || document;
			var classes = className.split(" "),
				classesToCheck = [],
				elements = (tag === "*" && el.all) ? el.all : el.getElementsByTagName(tag),
				current,
				returnElements = [],
				match;
			for (var k = 0, kl = classes.length; k < kl; k += 1)
				classesToCheck.push(new RegExp("(^|\\s)" + classes[k] + "(\\s|$)"));
			for (var l = 0, ll = elements.length; l < ll; l += 1) {
				current = elements[l];
				match = false;
				for (var m = 0, ml = classesToCheck.length; m < ml; m += 1) {
					match = classesToCheck[m].test(current.className);
					if (!match) break;
				}
				if (match) returnElements.push(current);
			}
			return returnElements;
		};
	}
	return getElementsByClassName(className, tag, el);
}