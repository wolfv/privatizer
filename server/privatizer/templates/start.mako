<%inherit file="base.mako"/>
<hr>
<div class="row">
	<div class="span7">
		<h1>Hi 
		% if user: 
			${user.user_name}
		% endif
			to the <i>Privatizer</i>.
		</h1>
	</div>
	<div class="span5 ">
		% if user == None:
		<span class="btn-group pull-right">
			<a class="btn btn-warning" href="${request.route_path('login')}"><i class="icon icon-lock"></i> Login</a>
			<a class="btn btn-success" href="${request.route_path('signup')}"><i class="icon icon-user"></i> Sign Up</a>
		</span>
		% else:
			<a class="btn pull-right btn-danger" href="${request.route_path('logout')}"><i class="icon-remove-circle"></i> Logout</a>
		% endif 
	</div>
</div>
<hr>
<div class="row">
<div class="span12">
	% if user is not None:

	<h2>Keys</h2>
	Add Keys, view keys and change permissions on your private keys. You also have the ability to view, which keys you can access.<br><br>
	<span class="btn-group">
		<a class="btn" href="${request.route_path('key.add')}"><i class="icon-plus"></i> Add Key</a>
		<a class="btn" href="${request.route_path('key.list')}"><i class="icon-list"></i> List Keys</a>
	</span>

	% endif 
</div>
</div>
<hr>
<div class="row">
	<div class="span12">
<h3>Download the Plugin</h3>
Feel free to download the Plugin here. As we don't yet have any autoupdate capability, please make sure to come back some time and check if there is a newer version for you. We will continue to improve reliability, performance and user interface drastically in the course of the next few weeks. <br><br>We furthermore plan to include many more websites for privatization than just (speaking as of now) fatzebook.<br> 
		<br><br>
		<a class="btn" href="${request.static_url('privatizer:static/download/plugin_chrome/privatizer.crx')}">
			<i class="icon-download"></i> Privatizer for <b>Chrome</b> or <b>Chromium</b>
		</a>
		<br>		<br>

		<a class="btn disabled"> 
			<i class="icon-download"></i> Privatizer for <b>Firefox</b> (coming soon, Georg is on it)
		</a>
<div class="row">
	<div class="span12">
<hr>

<div class="row">
	<div class="span12">

		<h5 style="text-align:center">PRIVATIZE THE WORLD </h5>
</div>
</div>