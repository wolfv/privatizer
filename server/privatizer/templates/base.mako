<!DOCTYPE html>
<html>
<head>
  <title>The Pyramid Web Application Development Framework</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="keywords" content="python web application" />
  <meta name="description" content="pyramid web application" />
  <link rel="shortcut icon" href="${request.static_url('privatizer:static/favicon.ico')}" />
  <link rel="stylesheet" href="${request.static_url('privatizer:static/css/styles.css')}" type="text/css" media="screen" charset="utf-8" />
</head>
<body>
  <div class="container">
    % if request.session.peek_flash():
    <hr>
    <% flash = request.session.pop_flash() %> 
    % for fm in flash:
      <div class="alert alert-${fm['type']['cssclass']}">
        <strong>${fm['type']['name']}!</strong>
        ${fm['message']}
      </div>
    % endfor
    % endif 
    
    ${self.body()}

    <%block name="form" />
  </div>
</body>
</html>