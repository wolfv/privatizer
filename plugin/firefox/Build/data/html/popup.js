function getKeys() {
	$.ajax({
		method: 'GET',
		username: localStorage['username'],
		password: localStorage['password'],
		url: 'http://privatizer.wolfvollprecht.de/key/index',
		response: 'jsonp',
		success: function(data) {
			console.log(data);
			$(data.items).each(function(i,d) {
				$('#keys').append(
					'<li>' + d.Name + '</li>'
				)
			});
		},
		error: function() {
			$('#login').show();
			console.log('error');
		}
	});
}
$(document).ready(function() {
	if(!localStorage['password']) {
		$('body').append('No Storage value for password.');
	}
	else {
		$('#login').hide();
		getKeys();
	}
	$('#Login').click(function(){
		localStorage['username'] = $('#username').val();
		localStorage['username'] = $('#username').val();
		$('#login').hide();
		getKeys();
	});
});