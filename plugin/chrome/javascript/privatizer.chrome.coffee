window.privatizer = {}

window.privatizer.xhrContainer = { count: 0, callbacks: [] }  

xhrContainer = window.privatizer.xhrContainer

window.privatizer.request = (data) ->
	
	request = new XMLHttpRequest()

	responseObject = {
		requestID: data.requestID,
	}

	request.addEventListener("load", (response) ->
		console.log 'request ready'
		console.log xhrContainer
		responseObject['text'] = response.target.responseText
		responseObject['status'] = response.target.status
		xhrContainer.callbacks[responseObject.requestID](responseObject);
		return responseObject
	, false)

	switch data.type
		when "POST"
			request.open "POST", data.url, true
		else
			request.open "GET", data.url, true
	
	request.setRequestHeader "Content-Type", "application/x-www-form-urlencoded; charset=UTF-8"

	request.withCredentials = true

	if data.header
		request.setRequestHeader data.header[0], data.header[1]
	#request.setRequestHeader data.header
	if data.content
		sendData = data.content
	else
		sendData = null

	request.send sendData