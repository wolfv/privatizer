<%inherit file="base.mako" /> 
<%block name="form">
<form method="POST" action="${url}">
<input type="hidden" name="came_from" value="${came_from}"/>
<div>
	<label for="name">Email</label>
	<input type="email" value="${login}" name="login"/>
</div>
<div>
	<label for="password">Passwort</label>
	<input type="password" name="password" value="${password}"/>
</div>
<input type="hidden" name="csrf" value="${request.session.get_csrf_token()}" />
<input type="submit" name="form.submitted" value="Log In"/>
</form>
</%block>