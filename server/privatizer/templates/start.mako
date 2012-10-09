<%inherit file="base.mako"/>
<div class="hero">
	<h1>Hi
	% if user:
		${user.user_name}
	% endif
		to the <i>Privatizer</i>.
	</h1>
</div>
<hr>
% if user is not None:

<div class="row">
<div class="span12">

	<h2>Keys</h2>
	Add Keys, view keys and change permissions on your private keys. You also have the ability to view, which keys you can access.<br><br>
	<span class="btn-group">
		<a class="btn" href="${request.route_path('key.add')}"><i class="icon-plus"></i> Add Key</a>
		<a class="btn" href="${request.route_path('key.list')}"><i class="icon-list"></i> List Keys</a>
	</span>
</div>
</div>
<hr>
% endif

<div class="row">
	<div class="span12">
<h3>Download the Plugin</h3>
Feel free to download the Plugin here. As we don't yet have any autoupdate capability, please make sure to come back some time and check if there is a newer version for you. We will continue to improve reliability, performance and user interface drastically in the course of the next few weeks. <br><br>We furthermore plan to include many more websites for privatization than just (speaking as of now) fatzebook.<br>
		<br><br>
		<a class="download download-chrome" href="${request.static_url('privatizer:static/download/plugin_chrome/privatizer.crx')}">
			 <span class="btn-text">Privatizer for <b>Chrome</b> or <b>Chromium</b></span><span class="icon"></span>
		</a>
		<br>		<br>
		We are happy to anounce the very first alpha-alpha release of privatizer for Firefox!
		<br><br>

		<a class="download download-firefox" href="${request.static_url('privatizer:static/download/plugin_firefox/privatizer.xpi')}">
			 <span class="btn-text">Privatizer for <b>Firefox</b> (&alpha;)</span><i class="icon"></i>
		</a>
<div class="row">
	<div class="span12">
<hr>

<div class="row">
	<div class="span12">

		<h5 style="text-align:center">PRIVATIZE THE WORLD </h5>
</div>
</div>
