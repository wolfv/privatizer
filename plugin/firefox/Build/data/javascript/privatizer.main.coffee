
purl = "http://wolle.crabdance.com:6543/"

preg = new RegExp "(:enc:)([^:]+):([^:]+):", "g"



Privatizer =
	login: (username, password) ->
		request = new Request({
			url: purl + "api/login",
			content: {"username": username, "password": password},
			onComplete: ->
				return request.response
		}).post()

	decryptDOM: () ->
		messages = []
		for classname in Plugin.classnames
			elements = document.getElementsByClassName classname
			if elements.length
				elements = Array.prototype.slice.call(elements)
				messages = elements.concat(messages)
		for msg in messages
			do ->
				dc = false
				decryptedText = msg.textContent.replace preg, ->
					console.log RegExp.$3 + " ... " + RegExp.$2	
					if RegExp.$1
						dc = true
					return Crypt.decrypt RegExp.$3, RegExp.$2, 256
				if dc
					oldHTML = msg.innerHTML
					msg.oldHTML = oldHTML
					msg.innerHTML = decryptedText + " [⚷]"
					msg.onmouseover = (e) -> 
						msg.innerHTML = msg.oldHTML
				return


Crypt = 
	encrypt: (value, keyhash) ->
		request = new XMLHttpRequest()
		request.open "GET", purl + "api/key/" + keyhash, false
		request.send null
		if request.readyState == 4 && request.status == 200
			json = JSON.parse request.response
			crypttext = Aes.Ctr.encrypt value, json.key, 256
			return keyhash + ":" + crypttext + ":"
		else if request.readyState == 4
			console.log request
			alert 'cannot encrypt the shizzle.'
			return false


	decrypt: (value, keyhash) ->
		request = new XMLHttpRequest()
		request.open "GET", purl + "api/key/" + keyhash, false
		request.send null
		if request.readyState == 4 && request.status == 200
			try
				json = JSON.parse request.response
				decryptedText = Aes.Ctr.decrypt(value, json.key, 256)
			catch error
				decryptedText =  "Sorry, something is wrong with the key. #{error}"
		else if request.readyState == 4
			decryptedText =  "Sorry, you don't have permissions to decrypt this."
		return decryptedText
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
				textarea.parentNode.insertBefore padlock, textarea.nextSibling
				
				padlock.onclick = (e) ->
					console.log 'padlock is clcikeded'
					if padlock.getAttribute('open') == '0'
						popup padlock
					e.stopPropagation()

				textarea.onblur = ->
					if this.getAttribute('encryption') != '1'
						this.setAttribute 'unencrypted', this.value
						this.setAttribute 'encryption', '1'
						if this.value
							this.value = ":enc:" + Crypt.encrypt this.value, padlock.getAttribute 'key'
				
				textarea.onfocus = ->
					if this.getAttribute('encryption') is '1'
						this.setAttribute 'encryption', '0'
						this.value = this.getAttribute 'unencrypted'

popup =
	isOpen: false
	
	open: ->
		if @isOpen
			return
		elem = document.getElementById 'privatizer-popup'
		if not elem
			elem = document.createElement('div')
			elem.id = 'privatizer-popup'
			elem.className = 'privatizer-popup visible'
			elem.style.position = 'absolute'
			elem.style.border = '1px solid #000'
			elem.style.zIndex = 10000

		offset = DOM.totalOffset(padlock)
		elem.style.left = offset['x'] + "px"
		elem.style.top = offset['y'] + 30 + "px"

		document.body.appendChild(elem)
		
		checktarget = (target) ->
			while target.parentNode 
				if target == elem
					return false
				else
					target = target.parentNode
			return true

		document.addEventListener('click', (e) ->
			if padlock.getAttribute('open') and checktarget(e.target)
				padlock.setAttribute 'open', '0'
				try
					elem.className = 'privatizer-popup hidden'
					elem.style.display = 'none'
			return
		)
		
		request = p_request({
			url: purl + "api/keys/list",
			method: 'POST',
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
									padlock.setAttribute 'key', @value
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
						return
				return
		});

		padlock.setAttribute 'open', '1'

		return 


document.addEventListener "DOMContentLoaded", ->
	console.log 'wir sind da. logs gehen?'
	if Plugin.classnames != undefined
		setInterval(
			->
				Privatizer.decryptDOM()
				DOM.findTextareas()
			, 1000)


	
