$(document).ready(function(){
	//auto-scrolling sidebar
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

	//window view of images
	function showFullSize(){
		var attr = $(this).attr('src');

	  if (typeof attr !== typeof undefined && attr !== false) {
      if (attr.indexOf('640x.')  > -1){
				var img = $("<img/>", {
					src: $(this).attr('src').replace('640x.', ''),
					alt: $(this).attr('alt'),
				});
				$("#image-frame").html(img);

				$("#image-modal").modal();
      }
	  }
	}

	$( "img" ).each(function() {
	  var attr = $(this).attr('src');

	  if (typeof attr !== typeof undefined && attr !== false) {
      if (attr.indexOf('640x.')  > -1){
				$(this).click(showFullSize);
      }
	  }
	});

	//newsletter modal
	if (window.location.hash == '#newsletterSignup') {
		$('#newsletterSignup').modal();
	}
});
