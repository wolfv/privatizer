regexp = new RegExp("(:enc:)([^:]+):([^:]+):", "g");
localStorage['defaultActive'] = true;

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

$('body').click(function(e) {
	e.target.innerHTML = e.target.innerHTML.replace(regexp, function() {
		console.log('test');
		return privatizer_decrypt(RegExp.$3, RegExp.$2, 256);
	});
});
$(".content").click(function(e) {
	e.target.innerHTML = e.target.innerHTML.replace(regexp, function() {
		console.log('test');
		return privatizer_decrypt(RegExp.$3, RegExp.$2, 256);
	});
});
$('.padlock').entwine({
	onmatch: function() {
		if($('parent').data('active')) {
			this.addClass('active');
		}
		else
		{
			this.removeClass('active');
		}
	},
	onclick: function() {
		if(this.parent().find('textarea').encryptionActive){
			this.removeClass('active');
			this.parent().find('textarea').encryptionActive = false;
			console.log(this.parent().find('textarea').encryptionActive);
		}
		else {
			this.addClass('active');
			this.parent().find('textarea').encryptionActive = true;
		}
	}
});
$('textarea').entwine({
	encryptionActive: localStorage['defaultActive'],
	onmatch: function() {
		var pad = $('<div class="padlock"></div>');
		var self = $(this);
		pad.toggle(function() {
			self.encryptionActive = localStorage['defaultActive'];
			console.log(self.encryptionActive);
		}, function(){
			self.encryptionActive = !localStorage['defaultActive'];
			console.log(self.encryptionActive);
		});
		$(this).after(pad);
	},
	onfocusin: function() {
		if($(this).data('encrypted')){
			$(this)
				.val($(this).data('rawtext'))
				.data('encrypted', false);
		}
		$(this).css({
			outline: '2px solid #FFFD85',
			outlineOffset: '0',
			border: '1px solid #FFB600'
		});
		console.log('asd');
	},
	onfocusout: function() {
		console.log('test');
		if(!localStorage['activeKey']){
			/*$('body').append('<div class="privatizer_popup">PickAKey</div>').css({
				'background' : '#FFF',
				'border' : 'gray 1px solid',
				'width': 300,
				'height': 200,
				'top' : '50%',
				'left' : '50%',
				'position': 'absolute'
			});*/
		}
		else { }
		if(!$(this).data('encrypted')) {
			$(this)
				.data('rawtext', $(this).val())
				.val(
					':enc:25ss:' + Aes.Ctr.encrypt($(this).val(), 'nicht', 256) + ':'
				)
				.data('encrypted', true);
		}
	},
	onkeydown: function(e) {
		console.log(e);
	}
});