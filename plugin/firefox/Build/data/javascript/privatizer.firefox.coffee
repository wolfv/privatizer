window.privatizer = {}

window.privatizer.xhrContainer = { count: 0, callbacks: [] }  

xhrContainer = window.privatizer.xhrContainer

self.port.on 'loadCSS', (message) ->
	style = document.createElement('style')
	style.type = 'text/css'
	style.appendChild(document.createTextNode(message.css));
	document.getElementsByTagName('head')[0].appendChild(style)

# Listener for Request Response
self.port.on 'requestCallback', (response) ->
	xhrContainer.callbacks[response.requestID](response);

window.privatizer.request = (data) ->
	self.port.emit 'request', data
