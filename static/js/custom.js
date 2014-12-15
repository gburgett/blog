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
});