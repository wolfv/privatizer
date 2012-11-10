<%inherit file="../base.mako" /> 
<%block name="form">
<form method="POST" action="${url}">
<input type="hidden" name="came_from" value="${came_from}"/>
<div>
	<label for="name">
	<span class="label-text">Email</span></label>
	<input 
		type="email"
		value="${login}" title="Email or Username" id="name"
		data-content="The email or the username you specified." name="login"/>
</div>
<div>
	<label for="password"><span class="label-text">Passwort</span></label>
	<input type="password" id="password" name="password" title="Password" data-content="Please tell us your secret password" value="${password}"/>
</div>
<hr>
<input type="hidden" name="csrf" value="${request.session.get_csrf_token()}" />
<input class="btn btn-primary" type="submit" name="form.submitted" value="Log In"/>
</form>
</%block>


<div class="row"><div class="span12">
	<h1>Login</h1>
	Welcome back. It's great to see you here, again.
	</div>
</div>
<hr>