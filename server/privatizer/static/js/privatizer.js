$(document).ready(function() {
	$('input').popover({
		'trigger': 'focus'
	});

	$('#generate_keytext').click(function(){
		var chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789äöü';
		console.log('abc')
		var output = '', chr;
		for(var i = 0; i <= 50; i++) {
			var randnum = Math.floor(Math.random() * chars.length)
			var chr = chars.charAt(randnum);
			output += chr;
		}
		console.log(output)
		$('#keytext').val(output)
		return false
	})

	function updatePermissions(data, elem) {
		key_id = data.key
		$.each(data.shared_with, function(index, el){
			elem.html('')
				.append($('<a>')
				.attr('href', 'keys/permission/delete/' + key_id + ':' + el.id)
				.addClass('btn btn-mini btn-danger delete-permission')
				.html(el.name));
		});
	}

	$('.add-permission').submit(function() {
		$.ajax({
			url: $(this).url,
			success: function(data) {
				updatePermissions(data, elem)
			}
		})
	})

	$('.delete-permission').live('click', function() {
		url = $(this).attr('href');
		$('#load-indicator').addClass('loading');
		elem = $(this).parent();
		$.ajax({
			url: url,
			success: function(data) {
				updatePermissions(data,elem);
			},
			dataType: 'json'
		});
		return false;
	})
})