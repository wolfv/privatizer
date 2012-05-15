/*
		FireFox-Plugin
*/


// Funktionsaufruf: Initialisierung der Variablen
var widgets, cm, tabs, windows, self, pageMod, notifications, ss, Request, menuitems
init_var()

if( ss.storage.firstRun == undefined ){
		// Funktionsaufruf: Erste Ausführung
		first_run()
}

// Funktionsaufruf: Erzeugt Browser-Menues
var privatizer_panel, menuitem, widget
var panel_height = 200
var panel_width = 180
create_menu()

// Funktionsaufruf: Läd die benötigten Content-Scripts
var pm
script_loads()

// Auf Änderung des Aktivierungszustandes warten:
privatizer_panel.port.on("event2", function(act) {
	ss.storage.activation = act;
	script_loads();
})



/*
		FUNCTION: Initialisiert Variablen
*/
function init_var(){
		widgets 	  = require("widget");
		cm			  = require("context-menu");
		tabs 		  = require("tabs");
		windows		  = require("windows").browserWindows;
		self		  = require("self");
		pageMod 	  = require("page-mod");
		notifications = require("notifications");
		ss 			  = require("simple-storage");
		Request 	  = require('request').Request;
		menuitems	  = require("menuitems");
}

/*
		FUNCTION: Erzeugt Menüführung im Browser
*/
function create_menu(){
		privatizer_panel = require("panel").Panel({
				height: panel_height,
				width: panel_width,
				contentURL: self.data.url("panel.html"),
				contentScriptFile: self.data.url("panelscript.js")
		})
		privatizer_panel.port.emit("event1", ss.storage.activation);
		
		menuitem = menuitems.Menuitem({
				id: "privatizer_menue",
				menuid: "menu_ToolsPopup",
				label: "Privatizer",
				onCommand: function() {
						privatizer_panel.show()
				}
		})
		
		cm.Item({
				label: "Privatizer",
				contentScript: "self.on('click', function(){self.postMessage()})",
				onMessage: function() {
						privatizer_panel.show()
				}
		})
		
		widget = widgets.Widget({
				id: "activation_privatizer",
				label: "Privatizer",
				contentURL: self.data.url("padlock.gif"),
				panel: privatizer_panel
		});
}

/*
		FUNCTION: Läd Content Scripts
*/
function script_loads(){
		
	console.log(ss.storage.activation)
	if( ss.storage.activation ){
		pm = pageMod.PageMod({
			include: "*.facebook.com",
			contentScriptWhen: 'ready',
			contentScriptFile: [
		      self.data.url("javascript/addons/facebook.js"),
			  self.data.url("javascript/thirdparty/encrypt.js"),
			  self.data.url("javascript/privatizer.firefox.js"),
			  self.data.url("javascript/privatizer.main.js")
			],
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
						request.headers = {"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"}
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
								content: request.data,
								withCredentials: true
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
								content: request.data,
								withCredentials: true
							}).get()
						} 
					}
				);
			}
		});
	}else{
		// Destruktor
		if( pm ){
			pm.destroy();
		}
	}

	// Läd die relevanten Tabs neu
	for(var i = 0; i<tabs.length; i++){
		if(tabs[i].url.substr(0, 23) == "http://www.facebook.com"){
			tabs[i].reload();
		}
	}
}

/*
		FUNKTION: Erster Start mit Plugin
*/
function first_run(){
		ss.storage.firstRun = false;
		ss.storage.activation = true;
		notifications.notify({
				title: "The Privatizer",
				text: "Thank you for using the Privatizer",
				iconURL: self.data.url("lock.png")
		})
		tabs.open({
				url: "wolle.crabdance.com:6543"
		});
		console.log("First Run detected!")
}
