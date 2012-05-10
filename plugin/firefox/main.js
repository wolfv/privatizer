//const widgets = require("widget");
//const tabs = require("tabs");
var self = require("self");
var pageMod = require("page-mod");

// Files included on facebook pages
pageMod.PageMod({
  include: "*.facebook.com",
  contentScriptWhen: 'end',
  contentScriptFile: [self.data.url("facebook.js"),
                      self.data.url("encrypt.js"),
                      self.data.url("privatizer.main.js")]
});

/*
// Privatizer turned off by default
var privatizer_activation = false;

// Erzeugt widget zum Umschalten des Privatizers
var widget = widgets.Widget({
  id: "activation_privatizer",
  label: "Privatizer",
  contentURL: "http://www.mozilla.org/favicon.ico",
  onClick: function() {
      if( privatizer_activation ){
        privatizer_activation = false
        console.log("Privatizer OFF")
        start_scripts()
      }else{
        privatizer_activation = true
        console.log("Privatizer ACTIVE")
        start_scripts()
      };
    }
});

function start_scripts() {
  if( privatizer_activation ){
    console.log("starting scripts")
    tabs.activeTab.reload()
  }else{
    console.log("relaoding page")
    tabs.activeTab.reload()
  }
}
*/