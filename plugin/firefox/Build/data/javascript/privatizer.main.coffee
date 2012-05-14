purl = "http://privatizer.crabdance.com/"

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
			content: "username=#{username}&password=#{password}",
			url: purl + "api/login",
			onload: (response) ->
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

				oldHTML = msg.innerHTML
				msg.oldHTML = oldHTML
				msg.innerHTML = decryptedText + " [⚷]"
				msg.onmouseover = (e) -> 
					msg.innerHTML = msg.oldHTML
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
					textarea.style.left < -1000 or
					textarea.style.left > 1000 or
					textarea.style.top < -1000
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
				
				# Blurring (e.g. clicking outside) the textarea
				# encrypts its contents

				textarea.onblur = ->
					if this.getAttribute('encryption') != '1'
						this.encrypted = true
						this.uncryptedText = this.value
						if this.uncryptedText && padlock.getAttribute 'key'
							Crypt.encrypt this, padlock.getAttribute 'key'
							
				# Focussing in the textarea restores unencrypted 
				# content

				textarea.onfocus = ->
					if this.encrypted
						this.value = this.uncryptedText

class Popup

	constructor: ->

		# Create a standard popup div

		elem = document.createElement('div')
		elem.id = 'privatizer-popup'
		elem.className = 'privatizer-popup visible'
		elem.style.position = 'absolute'
		elem.style.border = '1px solid #000'
		elem.style.zIndex = 10000
		elem.style.width = '235px'
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
									if padlock.textarea.encrypted == true
										Crypt.encrypt padlock.textarea, this.value
									else
										DOM.fireEvent padlock.textarea, 'blur'
						return

					when 403
						loginform = document.createElement 'form'
						reference = @
						loginform.onsubmit = (e) ->
							e.preventDefault()
							e.stopPropagation()
							response = Privatizer.login(
								loginform.elements['email'].value, 
								loginform.elements['password'].value
							)

						loginform.innerHTML = '
										<input type="email" name="email" placeholder="Email"></input>
										<input type="password" name="password" placeholder="Password"></input>
										<input type="submit" value="Login"/>'

						elem.innerHTML = '<h3>Login</h3>'
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


	
