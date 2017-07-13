$(document).ready(function(){
	$('#email').click(function(evt){
		evt.preventDefault();

		var at = '@';
		var e = 'gordon' + at + 'gordonburgett' + '.net';
		var link = $('<a>').attr('href', 'mailto:' + e).text(e);
		$('#email').empty();
		$('#email').append(link);
		$('#email').off();
	})

	$( "img" ).each(function() {
	  var attr = $(this).attr('src');

	  if (typeof attr !== typeof undefined && attr !== false) {
	    if (!window.matchMedia || !window.matchMedia("(max-width: 640px)").matches){
	      if (attr.indexOf('640x.')  > -1){
	      	attr = attr.replace('640x.', '')
	      	$(this).attr('src', attr);
	      }
	    }
	  }
	});
});
