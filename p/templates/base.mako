<!DOCTYPE html>
<html>
<head>
  <title>The Pyramid Web Application Development Framework</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="keywords" content="python web application" />
  <meta name="description" content="pyramid web application" />
  <link rel="shortcut icon" href="${request.static_url('p:static/favicon.ico')}" />
  <link rel="stylesheet" href="${request.static_url('p:static/css/styles.css')}" type="text/css" media="screen" charset="utf-8" />
</head>
<body>
  <div class="container">
    % if flash:
    <div class="alert">
      <strong>Attention!</strong>
      ${flash}
    </div>
    % endif 
    
    ${self.body()}

    <%block name="form" />
  </div>
</body>
</html>
