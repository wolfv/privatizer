textareas = document.getElementsByTagName 'textarea'

login = (username, password) ->
	request = new XMLHttpRequest()
	request.onreadystatechange = ->
		if request.readyState == 4
			console.log "Request for login"
			console.log request
			if request.status == 200
				console.log document.cookie
			return
		else 
			return
	
	request.open "POST", "http://localhost:6543/api/login", false
	request.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
	sendData = "username=#{username}&password=#{password}"
	request.send sendData


getKey = (hash) -> 
	console.log hash
	request = new XMLHttpRequest()
	
	#request.onreadystatechange = ->
	#	if request.readyState == 4 && request.status == 400
	#		console.log request
	#		return
	#	return

	#request.withCredentials = 1

	request.open "GET", "http://localhost:6543/api/key/1", true
	request.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
	request.withCredentials = "true"

	request.send null

document.addEventListener "DOMContentLoaded", ->
	console.log 'shizzle is ready'
	login 'p@p.de', 'p'
	btn = document.getElementById 'send'
	btn.onclick = ->
		console.log 'clicked'
		getKey('test')

	for ta in textareas
		do (ta) ->
			ta.className += " privatizer"
