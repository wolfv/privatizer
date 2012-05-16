purl = "http://privatizer.crabdance.com/"

preg = new RegExp "(:enc:)([^:]+):([^:]+):", "g"

Request = window.privatizer.request

xhrContainer = window.privatizer.xhrContainer

sendRequest = (request) ->
	request.requestID = xhrContainer.count;
	xhrContainer.callbacks[xhrContainer.count] = request.onload;
	Request(request)
	xhrContainer.count++

window.privatizer.crypt_before_send = (textarea, padlock) ->
	Crypt.encrypt(textarea, padlock.getAttribute 'key')

Privatizer =
	login: (username, password, padlock = null) ->
		sendRequest({
			type: "POST",
			content: "username=#{username}&password=#{password}",
			url: purl + "api/login",
			onload: (response) ->
				if padlock
					window.privatizer.popup.open(padlock)

				return
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
	# Function to encrypt contents of an textarea
	encrypt: (elem, keyhash) ->
		sendRequest({
			type: "GET",
			url: purl + "api/key/" + keyhash,
			onload: (response) ->
				if response.status == 200
					json = JSON.parse response.text
					crypttext = Aes.Ctr.encrypt elem.uncryptedText, json.key, 256
					elem.value = ":enc:" + keyhash + ":" + crypttext + ":"
					
					# Fire events in case there is a hidden textfield that
					# also needs to change value and does so with an eventlistener
					# of one of the following formats

					DOM.fireEvent(elem, 'change')
					DOM.fireEvent(elem, 'keyup')
					DOM.fireEvent(elem, 'keydown')
					DOM.fireEvent(elem, 'keypress')

				else
					console.log response
					console.log 'cannot encrypt the shizzle.'

		})
	# Function to decrypt an element
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

				oldHTML = msg.innerText
				
				cryptobutton = document.createElement 'span'
				cryptobutton.className = "cryptobutton"
				cryptobutton.oldHTML = oldHTML
				cryptobutton.innerHTML = "[V]"

				msg.innerHTML = decryptedText + " "
				msg.appendChild cryptobutton
				cryptobutton.onmouseover = (e) -> 
					reveal_text = document.createElement 'div'
					reveal_text.className = "reveal_text privatizer-popup"
					reveal_text.style.position = "absolute" 
					reveal_text.style.left = e.pageX + 'px'
					reveal_text.style.top = e.pageY + 'px'
					reveal_text.innerHTML = "<h3>Unencrypted Text</h3><p>" + this.oldHTML + "</p>"
					document.body.appendChild reveal_text
				cryptobutton.onmouseout = (e) ->
					els = document.body.getElementsByClassName('reveal_text')
					for el in els
						document.body.removeChild(el)
				return decryptedText
		})


# Document Object Model Helper functions

DOM =
	# Calculate the total offset to position the Popup
	totalOffset: (element) ->
		x = y = 0
		while element.offsetParent
			x += element.offsetLeft
			y += element.offsetTop
			element = element.offsetParent
		return {x: x, y: y}

	fireEvent: (element, event) ->
		evt = document.createEvent "HTMLEvents"
		evt.initEvent event, true, false
		element.dispatchEvent(evt)

	# Not used yet, might be used later to fade in the 
	# Element
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

	# Find all textareas in the DOM

	findTextareas: () ->
		textareas = document.getElementsByTagName "textarea"
		
		# Loop through all textareas
		for textarea in textareas
			do ->
				# If textarea is already in the set or not visible
				# Don't attach a padlock
				
				if (textarea.padlock != undefined or
					textarea.style.display == 'none' or
					textarea.style.visibility == 'hidden' or
					textarea.style.opacity == 0 or
					textarea.offsetLeft < -1000 or
					textarea.offsetLeft > 1000 or
					textarea.offsetTop < -1000

				)
					return false

				# Append the attributes for privatizer
				
				textarea.setAttribute 'encryption', '0'
				textarea.setAttribute 'unencrypted', textarea.value

				textarea.encrypted = false
				textarea.uncryptedText = ""

				# Create the Padlock

				padlock = document.createElement 'span'
				padlock.className = "privatizer-padlock"
				padlock.innerHTML = "A" # Iconfont: Key
				padlock.setAttribute 'open', 0
				padlock.setAttribute 'key', 0
				padlock.setAttribute 'tabindex', 0
				# Insert the padlock
				# Find the position (defined in the plugin.js)

				Plugin.findPosition textarea, padlock

				# Add cross references to both elements
				# Might be useful later

				textarea.padlock = padlock
				padlock.textarea = textarea

				# Add the eventlistener to open the popup

				padlock.addEventListener('click', (e) ->
					window.privatizer.popup.open(padlock)
					e.stopPropagation()
				, true)
				
				# Focussing with tab opens popup

				padlock.addEventListener('focus', (e) ->
					window.privatizer.popup.open(padlock)
					e.stopPropagation()
				, true)
				
				# Blur with next tab closes Popup

				#padlock.addEventListener('blur', (e) ->
				#	window.privatizer.popup.close(e)
				#	e.stopPropagation()
				#, true)

				# Blurring (e.g. clicking outside) the textarea
				# encrypts its contents

				textarea.onblur = ->
					if padlock.textarea.encrypted != true and padlock.textarea.value != padlock.textarea.placeholder
						padlock.textarea.encrypted = true
						padlock.textarea.uncryptedText = this.value
						if padlock.textarea.uncryptedText && padlock.getAttribute 'key'
							Crypt.encrypt padlock.textarea, padlock.getAttribute 'key'
							
				# Focussing in the textarea restores unencrypted 
				# content

				textarea.onfocus = ->
					if this.encrypted && this.value != '' && this.value != this.placeholder
						this.value = this.uncryptedText
						this.encrypted = false

				textarea.onsubmit = (e) ->
					this.value = "Aha."
					e.stopPropagation()
					e.preventDefault()

class Popup

	constructor: ->

		# Create a standard popup div

		elem = document.createElement('div')
		elem.id = 'privatizer-popup'
		elem.className = 'privatizer-popup visible'
		elem.style.position = 'absolute'
		elem.style.display = 'none'
		@Element = elem
		document.body.appendChild(@Element)

	Element: null

	# Parent padlock
	Padlock: null
	
	# Is the popup open?
	isOpen: false
	
	# close action
	close: (e) ->
		# If event because of escape not mouse
		if not e 
			if @isOpen
				@Padlock.setAttribute 'open', '0'
				try
					@Element.className = 'privatizer-popup hidden'
					@Element.style.display = 'none'
					@isOpen = false
					window.onkeydown = () ->
			return

		# If event from mouse
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
				window.onkeydown = () ->
		return

	open: (padlock) -> 
		
		if @isOpen and @Padlock == padlock
			return
		
		@Padlock = padlock
		
		offset = DOM.totalOffset(@Padlock)
		
		elem = @Element

		elem.style.left = offset['x'] + "px"
		elem.style.top = offset['y'] + 30 + "px"

		window.onkeydown = (e) ->
			if e.keyCode == 40 # ARROW UP
				e.preventDefault()
				selects = elem.getElementsByTagName 'input'
				for select in selects
					if next
						select.checked = true
						select.onchange()
						break
					if select.checked
						next = true
				# If no select checked
				if !next
					selects[0].checked = true
			
			else if e.keyCode == 38 # ARROW DOWN
				e.preventDefault()
				selects = elem.getElementsByTagName 'input'
				for select in selects
					if select.checked
						if prevSelect
							prevSelect.checked = true
							prevSelect.onchange()
							break
						else 
							select.checked = true
					prevSelect = select

			else if e.keyCode == 27 #ESCAPE
				window.privatizer.popup.close(null)
				e.preventDefault()


		elem.style.display = 'block'
		elem.innerHTML = ''
		request = sendRequest({
			type: "GET",
			url: purl + "api/keys/list",		
			onload: (response) ->

				switch response.status
					when 200
						json = JSON.parse response.text
						elem.innerHTML = '<h3>Keys</h3>'
						ul = elem.appendChild document.createElement 'ul'
						for key in json
							do ->
								radio  = document.createElement 'input'
								radio.setAttribute 'type', 'radio'
								radio.id = 'pkey-' + key.hash
								radio.value = key.hash
								radio.setAttribute 'name', 'keys'
								
								label = document.createElement 'label'
								label.innerHTML = "<span class=\"labelrow\"><span class=\"name\" title=\"#{key.description}\">#{key.name}</span> <span class=\"description\" title=\"#{key.description}\">#{key.description}</span></span>"
								label.setAttribute 'for', 'pkey-' + key.hash
								label.setAttribute 'tabindex', 0

								user_badge = hidden_user_badge = ""

								for user in key.shared_with[0..5]
									user_badge += "<a class=\"user_badge\">#{user.name}</a> "
								if key.shared_with.length == 0
									user_badge = "private key"
								label.innerHTML += "<span class=\"labelrow\">#{user_badge}</span>"
								for user in key.shared_with[5..]
									hidden_user_badge += "<a class=\"user_badge\">#{user.name}</a> "

								label.user_badge = user_badge
								label.hidden_user_badge = hidden_user_badge

								li = ul.appendChild document.createElement 'li' 
								li.appendChild radio
								li.appendChild label
								radio.onchange = -> 
									padlock.setAttribute 'key', this.value
									if padlock.textarea.encrypted == true
										Crypt.encrypt padlock.textarea, this.value
									else
										DOM.fireEvent padlock.textarea, 'blur'
						info = document.createElement 'p'
						info.className = "privatizer_footer"
						info.innerHTML = "You can modify your keys at <a href=\"#{purl}\" target=\"_blank\">privatizer</a>"
						elem.appendChild info
						return

					else
						loginform = document.createElement 'form'
						reference = @
						loginform.onsubmit = (e) ->
							e.preventDefault()
							e.stopPropagation()
							response = Privatizer.login(
								loginform.elements['email'].value, 
								loginform.elements['password'].value,
								padlock
							)
							window.privatizer.popup.close()

						loginform.innerHTML = '
								<input id="privatizer_email" type="email" name="email" placeholder="Email" tabindex="0"></input>
								<input type="password" name="password" placeholder="Password" tabindex="0"></input>
								<input type="submit" value="Login" tabindex="0"/>
							'
						loginform.elements[0].focus()
						elem.innerHTML = '<h3>Login</h3>'
						elem.appendChild loginform
		});

		document.addEventListener('click', (e) ->
			console.log e
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


	
