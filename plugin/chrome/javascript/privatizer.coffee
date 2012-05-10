textareas = document.getElementsByTagName 'textarea'
purl = "http://localhost:6543/"

preg = new RegExp "(:enc:)([^:]+):([^:]+):", "g"

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
	
	request.open "POST", purl + "api/login", false
	request.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
	sendData = "username=#{username}&password=#{password}"
	request.send sendData


getKey = (hash) -> 
	console.log hash
	request = new XMLHttpRequest()
	
	request.onreadystatechange = ->
		if request.readyState == 4 && request.status == 200
			json = JSON.parse request.response
			console.log json.key
			btn = document.getElementById 'send'
			btn.innerHTML = 'success.'
			return
		return

	
	request.open "GET", purl + "api/key/1", true
	request.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
#	request.withCredentials = "true"

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
