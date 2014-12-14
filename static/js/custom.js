$(document).ready(function(){
	$('#email').click(function(evt){
		evt.preventDefault();

		var e = 'gordon' + '.burgett' + '@gmail' + '.com';
		var link = $('<a>').attr('href', 'mailto:' + e).text(e);
		$('#email').empty();
		$('#email').append(link);
		$('#email').off();
	})
});