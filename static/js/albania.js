$(document).ready(function(){
	ul = $("#h-sidebar")

	lasth1 = undefined
	lasth1sublist = undefined
	lasth2 = undefined
	lasth2sublist = undefined
	$("#content :header").each(function(index) {
		me = $(this)

		if (me.is("h1")) {
			lasth1 = me
			list = ul
		} else if(me.is("h2")) {
			lasth2 = me
			list = lasth1sublist
		} else if(me.is("h3")) {
			list = lasth2sublist
		} else {
			return
		}

		sublist = $("<ul class='nav nav-stacked'/>")
		li = $("<li/>").append(
			$("<a/>").attr("href", "#" + me.attr("id")).append(me.text()),
			sublist
			)
		list.append(li)

		if (me.is("h1")) {
			lasth1sublist = sublist
		} else if (me.is("h2")) {
			lasth2sublist = sublist
		}
	})

	$('body').scrollspy({
	    target: '.bs-docs-sidebar',
	    offset: 100
	});
});