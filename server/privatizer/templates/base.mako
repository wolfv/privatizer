<!DOCTYPE html>
<html>
<head>

	<title>Privatizer | Regain privacy in the twenty-first century</title>
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
	<meta name="keywords" content="python web application" />
	<meta name="description" content="pyramid web application" />

	<link rel="shortcut icon" href="${request.static_url('privatizer:static/favicon.png')}" />
	<link rel="stylesheet" href="${request.static_url('privatizer:static/css/styles.css')}" type="text/css" media="screen" charset="utf-8" />
	<link href='http://fonts.googleapis.com/css?family=Source+Sans+Pro:400,600,700' rel='stylesheet' type='text/css'>

	<script src="${request.static_url('privatizer:static/js/jquery.js')}"></script>
	<script src="${request.static_url('privatizer:static/js/jquery-ui.js')}"></script>
	<script src="${request.static_url('privatizer:static/js/underscore.js')}"></script>
	<script src="${request.static_url('privatizer:static/js/json2.js')}"></script>
	<script src="${request.static_url('privatizer:static/js/backbone.js')}"></script>
	<script src="${request.static_url('privatizer:static/js/bootstrap.js')}"></script>
	<script src="${request.static_url('privatizer:static/js/chosen/chosen.jquery.js')}"></script>
	<script src="${request.static_url('privatizer:static/js/privatizer.server.js')}"></script>

</head>
<body>
	<!--<div class="row big-teaser">
		<div class="container">
			<div class=" big-lock">

			</div>
			<div class="text">
				<h1>privatizer</h1>
				<h3>military grade encryption <br>at your fingertip<h3>
				<a class="btn big-button"><b>Privatizer Plugin</b><br><small>for Chrome<br>version 0.0.1<small></a>
			</div>
		</div>
	</div>-->
	<header>
		<div>
			<a href="/" class="logo">
				<img src="${request.static_url('privatizer:static/img/logo.png')}" title="Get Privatizer Homepage" alt="Logo for privatizer">
			</a>
			<nav class="nav">
				<a href="download"><i class="icon-download"></i> Download</a> 
				% if user:
					<a href="${request.route_path('logout')}"><i class="icon-remove-circle"></i> Logout</a>
				% else:
					<a href="${request.route_path('login')}"><i class="icon icon-lock"></i> Login</a>
					<a class="link-signup" href="${request.route_path('signup')}"><i class="icon icon-user"></i> Sign Up</a>					
				% endif
			</nav>
			<div class="x"></div>
		</div>
	</header>
	</div>
	<div class="container content">
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
