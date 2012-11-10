<%inherit file="../base.mako"/>
<%block	name="form">
	<form method="POST" action="/signup">
	<div>
		<label for="name">
		<span class="label-text">Name</span></label>
		<input type="text" name="name" id="name" placeholder="Please choose a username you like"/>
	</div>
	<div>
		<label for="email"><span class="label-text">Email</span></label>
		<input type="email" name="email" id="email" placeholder="Email" placeholder="Please let us know your Email"/>
	</div>

	<div>
		<label for="password"><span class="label-text">Passwort</span></label>
		<input type="password" name="password" id="password" placeholder="Choose a password"/>
	</div>
	<div>
		<label for="password_retype"><span class="label-text">Passwort wiederholen</span></label>
		<input type="password" name="password_retype" id="password_retype" placeholder="Retype your password" />
	</div>
	<hr>
	<input type="hidden" name="csrf" value="${request.session.get_csrf_token()}" />
	<input class="btn btn-primary " type="submit" name="form.submitted" value="Submit"/>
	</form>
</%block>
<div class="row"><div class="span12">
	<h1>Sign Up</h1>
	A very warm welcome to us privatizers. We are many. And we will succeed.
	</div>
</div>
<hr>