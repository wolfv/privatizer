regexp = new RegExp("(:enc:)([^:]+):([^:]+):", "g");

function privatizer_decrypt(message, passhash, bitlength) {
	var result = "Empty";
	$.ajax({
		url: "http://privatizer.wolfvollprecht.de/key/retrieve/" + passhash,
		type: "GET",
		response: "jsonp",
		async: false,
		success: function(data) {
			result = Aes.Ctr.decrypt(message, data.KeyText, bitlength);
		},
		error: function() {
			result = "Not Possible to decrypt";
		}
	});
	return result;
}

$(".content").click(function(e) {
	e.target.innerHTML = e.target.innerHTML.replace(regexp, function() {
		return privatizer_decrypt(RegExp.$3, RegExp.$2, 256);
	});
});

$('textarea')
	.focus(function(e) {
		$(this).css({
			outline: '2px solid #FFFD85',
			outlineOffset: '0',
			border: '1px solid #FFB600'
		});
	})
	.blur(function(e){
		console.log($(this).val(
			':enc:25ss:' + Aes.Ctr.encrypt($(this).val(), 'nicht', 256) + ':'
		));
	});