<%inherit file="base.mako"/>
<%block	name="form">
	<form method="POST" action="/signup">
	<div>
		<label for="name">Name</label>
		<input type="text" name="name" placeholder="Please choose a username you like"/>
	</div>
	<div>
		<label for="email">Email</label>
		<input type="email" name="email" placeholder="Email" placeholder="Please let us know your Email"/>
	</div>

	<div>
		<label for="password">Passwort</label>
		<input type="password" name="password" placeholder="Choose a password"/>
	</div>
	<div>
		<label for="password_retype">Passwort wiederholen</label>
		<input type="password" name="password_retype" placeholder="Retype your password" />
	</div>
	<hr>
	<input type="hidden" name="csrf" value="${request.session.get_csrf_token()}" />
	<input class="btn btn-primary " type="submit" name="form.submitted" value="Submit"/>
	</form>
</%block>

<hr>
<div class="row"><div class="span12">
	<h1>Sign Up</h1>
	A very warm welcome to us privatizers. We are many. And we will succeed.
	</div>
</div>
<hr>