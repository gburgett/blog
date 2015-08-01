$(document).ready(function(){
	$('#email').click(function(evt){
		evt.preventDefault();

		var at = '@';
		var e = 'gordon' + '.burgett' + at + 'gmail' + '.com';
		var link = $('<a>').attr('href', 'mailto:' + e).text(e);
		$('#email').empty();
		$('#email').append(link);
		$('#email').off();
	})

	$( "img.data-img" ).each(function() {
	  var attr = $(this).attr('data-image-src');

	  if (typeof attr !== typeof undefined && attr !== false) {
	    if (window.matchMedia && window.matchMedia("(max-width: 640px)").matches){
			arr = attr.split('.')
			end = arr.pop()
			arr.push('640x', end)
	      $(this).attr('src', arr.join('.'));
	    } else {
	      $(this).attr('src', attr);
	    }
	  }
	});
});