purl = "http://wolle.crabdance.com:6543/"

preg = new RegExp "(:enc:)([^:]+):([^:]+):", "g"

Request = window.privatizer.request

xhrContainer = window.privatizer.xhrContainer

sendRequest = (request) ->
	request.requestID = xhrContainer.count;
	xhrContainer.callbacks[xhrContainer.count] = request.onload;
	Request(request)
	xhrContainer.count++

Privatizer =
	login: (username, password) ->
		sendRequest({
			type: "POST",
			data: "username=#{username}&password=#{password}",
			url: purl + "api/login",
			onload: (response) ->
				return response
		});

	decryptDOM: () ->
		messages = []
		for classname in Plugin.classnames
			elements = document.getElementsByClassName classname
			if elements.length
				elements = Array.prototype.slice.call(elements)
				messages = elements.concat(messages)
		for msg in messages
			do ->
				msg.textContent.replace preg, ->
					if RegExp.$1
						Crypt.decrypt msg, RegExp.$3, RegExp.$2


Crypt = 
	encrypt: (elem, keyhash) ->
		sendRequest({
			type: "GET",
			url: purl + "api/key/" + keyhash,
			onload: (response) ->
				if response.status == 200
					json = JSON.parse response.text
					crypttext = Aes.Ctr.encrypt elem.value, json.key, 256
					elem.value = ":enc:" + keyhash + ":" + crypttext + ":"
				else
					console.log response
					console.log 'cannot encrypt the shizzle.'

		})

	decrypt: (msg, value, keyhash) ->
		sendRequest({
			url: purl + "api/key/" + keyhash,
			onload: (response) -> 
				if response.status == 200
					try
						json = JSON.parse response.text
						decryptedText = Aes.Ctr.decrypt(value, json.key, 256)
					catch error
						decryptedText =  "Sorry, something is wrong with the key. #{error}"
				else
					decryptedText =  "Sorry, you don't have permissions to decrypt this."

				oldHTML = msg.innerHTML
				msg.oldHTML = oldHTML
				msg.innerHTML = decryptedText + " [⚷]"
				msg.onmouseover = (e) -> 
					msg.innerHTML = msg.oldHTML
				return decryptedText
		})


DOM =
	totalOffset: (element) ->
		x = y = 0
		while element.offsetParent
			x += element.offsetLeft
			y += element.offsetTop
			element = element.offsetParent
		return {x: x, y: y}
	fadeIn: (element, speed = 100) ->
		opacity = element.style.opacity
		interval = setInterval( 
			->
				opacity += 0.1
				element.style.opacity = opacity
				if opacity > 1
					clearInterval(intveral)
					opacity = 1
					element.style.opacity = opacity
			, speed)
	fadeOut: (element, speed = 100) ->
		opacity = element.style.opacity
		interval = setInterval( 
			->
				opacity -= 0.1
				element.style.opacity = opacity
				if opacity < 0
					clearInterval(intveral)
					opacity = 0
					element.style.opacity = opacity
			, speed)

	findTextareas: () ->
		textareas = document.getElementsByTagName "textarea"
		
		for textarea in textareas
			do ->
				if (textarea.hasAttribute('encryption') or
					textarea.style.display == 'none' or
					textarea.style.visibility == 'hidden' or
					textarea.style.opacity == 0 
				)
					return false

				textarea.setAttribute 'encryption', '0'
				textarea.setAttribute 'unencrypted', textarea.value

				padlock = document.createElement 'span'
				padlock.className = "privatizer-padlock"
				padlock.innerHTML = "A" # Iconfont: Key
				padlock.setAttribute 'open', 0
				padlock.setAttribute 'key', 0
				textarea.parentNode.insertBefore padlock, textarea.nextSibling
				
				padlock.addEventListener('click', (e) ->
					window.privatizer.popup.open(padlock)
					e.stopPropagation()
				, true)
				
				textarea.onblur = ->
					if this.getAttribute('encryption') != '1'
						this.setAttribute 'unencrypted', this.value
						this.setAttribute 'encryption', '1'
						if this.value && padlock.getAttribute 'key'
							Crypt.encrypt this, padlock.getAttribute 'key'
				
				textarea.onfocus = ->
					if this.getAttribute('encryption') is '1'
						this.setAttribute 'encryption', '0'
						this.value = this.getAttribute 'unencrypted'

class Popup

	constructor: ->
		elem = document.createElement('div')
		elem.id = 'privatizer-popup'
		elem.className = 'privatizer-popup visible'
		elem.style.position = 'absolute'
		elem.style.border = '1px solid #000'
		elem.style.zIndex = 10000
		@Element = elem
		document.body.appendChild(@Element)

	Element: null

	# Parent padlock
	Padlock: null
	
	# Is the popup open?
	isOpen: false
	
	# close action
	close: (e) ->
		elem = @Element
		checktarget = (target) ->
			while target.parentNode 
				if target == elem
					return false
				else
					target = target.parentNode
			return true

		if @isOpen and checktarget(e.target)
			@Padlock.setAttribute 'open', '0'
			try
				@Element.className = 'privatizer-popup hidden'
				@Element.style.display = 'none'
				@isOpen = false
		return

	open: (padlock) -> 
		
		if @isOpen and @Padlock == padlock
			return
		
		@Padlock = padlock
		
		offset = DOM.totalOffset(@Padlock)
		
		elem = @Element

		elem.style.left = offset['x'] + "px"
		elem.style.top = offset['y'] + 30 + "px"

		elem.style.display = 'block'
		elem.innerHTML = ''
		request = sendRequest({
			type: "GET",
			url: purl + "api/keys/list",		
			onload: (response) ->

				switch response.status
					when 200
						json = JSON.parse response.text
						ul = elem.appendChild document.createElement 'ul'
						for key in json
							do ->
								radio  = document.createElement 'input'
								radio.setAttribute 'type', 'radio'
								radio.id = 'pkey-' + key.hash
								radio.value = key.hash
								radio.setAttribute 'name', 'keys'
								
								label = document.createElement 'label'
								label.innerHTML = "<span class=\"name\">#{key.name}</span><span class=\"description\">#{key.description}</span>"
								label.setAttribute 'for', 'pkey-' + key.hash

								li = ul.appendChild document.createElement 'li' 
								li.appendChild radio
								li.appendChild label
								radio.onchange = -> 
									padlock.setAttribute 'key', this.value
						return

					when 403
						loginform = document.createElement 'form'
						loginform.onsubmit = (e) ->
							e.preventDefault()
							response = Privatizer.login(loginform.elements['email'].value, loginform.elements['password'].value)
							console.log response
							popup(padlock)
						loginform.innerHTML = '
										<input type="email" name="email" placeholder="Email"></input>
										<input type="password" name="password" placeholder="Password"></input>
										<input type="submit" value="Login"/>'

						elem.innerHTML = '<h3>Login Dring</h3>'
						elem.appendChild loginform
					else 
						console.log 'das war wohl nix? obwohl 403, eiegntlich'
		});

		document.addEventListener('click', (e) ->
			window.privatizer.popup.close(e)
			return true
		, false)

		@isOpen = true
		
		@Padlock.setAttribute 'open', '1'

document.addEventListener "DOMContentLoaded", ->
	window.privatizer = {}
	window.privatizer.popup = new Popup()

	console.log 'wir sind da. logs gehen?'
	if Plugin.classnames != undefined
		setInterval(
			->
				Privatizer.decryptDOM()
				DOM.findTextareas()
			, 1000)


	
