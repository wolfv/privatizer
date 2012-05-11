const widgets = require("widget");
const tabs = require("tabs");
var self = require("self");
var pageMod = require("page-mod");
var ss = require("simple-storage");
var pm;
if( ss.storage.firstRun == undefined ){
  ss.storage.firstRun = false;
  ss.storage.activation = false;
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
  if( ss.storage.activation ){
    pm = pageMod.PageMod({
      include: "*.facebook.com",
      contentScriptWhen: 'ready',
      contentScriptFile: [self.data.url("javascript/addons/facebook.js"),
                          self.data.url("javascript/thirdparty/encrypt.js"),
                          self.data.url("javascript/privatizer.main.js")],
      contentScript: "onMessage = function onMessage(message) {" +
                            "    var style = document.createElement('style');" +
                            "    style.type = 'text/css';" +
                            "    style.appendChild(document.createTextNode(message));" +
                            "    document.getElementsByTagName('head')[0].appendChild(style);" +
                            "};",
      onAttach: function(worker) {
        worker.postMessage(self.data.load("css/style_inline.css"));
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