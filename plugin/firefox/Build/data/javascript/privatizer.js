// Generated by CoffeeScript 1.3.1
(function() {
  var getKey, login, preg, purl, textareas;

  textareas = document.getElementsByTagName('textarea');

  purl = "http://localhost:6543/";

  preg = new RegExp("(:enc:)([^:]+):([^:]+):", "g");

  login = function(username, password) {
    var request, sendData;
    request = new XMLHttpRequest();
    request.onreadystatechange = function() {
      if (request.readyState === 4) {
        console.log("Request for login");
        console.log(request);
        if (request.status === 200) {
          console.log(document.cookie);
        }
      } else {

      }
    };
    request.open("POST", purl + "api/login", false);
    request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    sendData = "username=" + username + "&password=" + password;
    return request.send(sendData);
  };

  getKey = function(hash) {
    var request;
    console.log(hash);
    request = new XMLHttpRequest();
    request.onreadystatechange = function() {
      var btn, json;
      if (request.readyState === 4 && request.status === 200) {
        json = JSON.parse(request.response);
        console.log(json.key);
        btn = document.getElementById('send');
        btn.innerHTML = 'success.';
        return;
      }
    };
    request.open("GET", purl + "api/key/1", true);
    request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    return request.send(null);
  };

  document.addEventListener("DOMContentLoaded", function() {
    var btn, ta, _i, _len, _results;
    console.log('shizzle is ready');
    login('p@p.de', 'p');
    btn = document.getElementById('send');
    btn.onclick = function() {
      console.log('clicked');
      return getKey('test');
    };
    _results = [];
    for (_i = 0, _len = textareas.length; _i < _len; _i++) {
      ta = textareas[_i];
      _results.push((function(ta) {
        return ta.className += " privatizer";
      })(ta));
    }
    return _results;
  });

}).call(this);
