var widgets 	= require("widget");
var tabs 		= require("tabs");
var self		= require("self");
var pageMod 	= require("page-mod");
var ss 			= require("simple-storage");
var Request 	= require('request').Request;

var pm;
if( ss.storage.firstRun == undefined ){
	ss.storage.firstRun = false;
	ss.storage.activation = true;
	console.log("First Run detected!")
}

// Files included on facebook pages
script_loads();

var privatizer_panel = require("panel").Panel({
	height: 140,
	width: 180,
	contentURL: self.data.url("panel.html"),
	contentScriptFile: self.data.url("panelscript.js")
})

privatizer_panel.port.emit("event1", ss.storage.activation);
privatizer_panel.port.on("event2", function(act) {
	ss.storage.activation = act;
	script_loads();
})

// Erzeugt widget zum Umschalten des Privatizers
var widget = widgets.Widget({
	id: "activation_privatizer",
	label: "Privatizer",
	contentURL: self.data.url("padlock.gif"),
	panel: privatizer_panel
});

function script_loads(){

	request = Request({
		url: "http://wolle.crabdance.com:6543/api/keys/list",
		onComplete: function(response) {
			console.log(response.status);
		}
	}).get();

	if( ss.storage.activation ){
		pm = pageMod.PageMod({
			include: "*",
			contentScriptWhen: 'ready',
			contentScriptFile: [
			  self.data.url("javascript/addons/facebook.js"),
			  self.data.url("javascript/thirdparty/encrypt.js"),
			  self.data.url("javascript/privatizer.firefox.js"),
			  self.data.url("javascript/privatizer.main.js")
			],
			contentScript: "",
			onAttach: function(worker) {
				
				// Initialize CSS for inline
				initMessage = { 
					type: 'init', 
					css: self.data.load("css/style_inline.css")
				}

				worker.port.emit('loadCSS', initMessage);
				
				worker.port.on('fireRequest', function(data) {
					request = Request({
						url: "http://wolle.crabdance.com:6543/api/keys/list",
						onComplete: function(response) {
							console.log(response.status);
						}
					}).get();
				});
				worker.port.on('request', 
					function(request) {
						var responseObj = {
							"requestID": request.requestID,
						}
						if(request.type == 'POST'){
							Request({
								url: request.url,
								onComplete: function(response) {
									responseObj['text'] = response.text;
									responseObj['status'] = response.status;
									worker.port.emit('requestCallback', responseObj);
								},
								headers: request.headers,
								content: request.data
							}).post()
						} else {
							Request({
								url: request.url,
								onComplete: function(response) {
									responseObj['text'] = response.text;
									responseObj['status'] = response.status;
									worker.port.emit('requestCallback', responseObj);
								},
								headers: request.headers,
								content: request.data
							}).get()
						} 
					}
				);
			}
		});
	}else{
		if( pm ){
			pm.destroy();
		}
	}

	for(var i = 0; i<tabs.length; i++){
		if(tabs[i].url.substr(0, 23) == "http://www.facebook.com"){
			tabs[i].reload();
		}
	}
}