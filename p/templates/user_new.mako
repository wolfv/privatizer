<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" xmlns:tal="http://xml.zope.org/namespaces/tal">
<head>
  <title>The Pyramid Web Application Development Framework</title>
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
  <meta name="keywords" content="python web application" />
  <meta name="description" content="pyramid web application" />
  <link rel="shortcut icon" href="${request.static_url('p:static/favicon.ico')}" />
  <link rel="stylesheet" href="${request.static_url('p:static/pylons.css')}" type="text/css" media="screen" charset="utf-8" />
  <link rel="stylesheet" href="http://static.pylonsproject.org/fonts/nobile/stylesheet.css" media="screen" />
  <link rel="stylesheet" href="http://static.pylonsproject.org/fonts/neuton/stylesheet.css" media="screen" />
  <!--[if lte IE 6]>
  <link rel="stylesheet" href="${request.static_url('p:static/ie6.css')}" type="text/css" media="screen" charset="utf-8" />
  <![endif]-->
</head>
	<body>
	  % if flash:
	  <div class="flash">
	  	${flash}
	  </div>
	  % endif 
	  <form method="POST" action="/signup">
	    <div>
	    	<label for="name">Name</label>
			<input type="text" name="name"/>
	    </div>
	    <div>
	    	<label for="email">Name</label>
			<input type="email" name="email"/>
	    </div>

	    <div>
	    	<label for="password">Passwort</label>
	    	<input type="password" name="password" />
	    </div>
	    <div>
	    	<label for="password_retype">Passwort wiederholen</label>
	    	<input type="password" name="password_retype" />
	    </div>
	    <input type="hidden" name="csrf" value="${request.session.get_csrf_token()}" />
	    <input type="submit" name="form.submitted" value="Submit"/>
	  </form>
	</body>
</html>
