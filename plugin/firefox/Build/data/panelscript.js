activation = false;

self.port.on("event1", function(act) {
  activation = act;
  reload();
});

var button = document.getElementById("change_status");
button.onclick = function(){
    if( activation ){
        activation = false;
    }else{
        activation = true;
    }
    reload();
    self.port.emit("event2", activation);
}

function reload(){
  if( activation ) {
    document.getElementById("Status").innerHTML = "<img src='lock_closed.png'/>"
    document.getElementById("change_status").value = "Disable"
  } else {
    document.getElementById("Status").innerHTML = "<img src='lock_open.png'/>"
    document.getElementById("change_status").value = "Activate"
  }
}