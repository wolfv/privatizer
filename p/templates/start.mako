<%inherit file="base.mako"/>

<h1>Hi</h1>to the Privatizer.

You can login to check your keys, contacts and various permissions.

<a href="${request.route_path('login')}">Login</a>
<a href="${request.route_path('logout')}">Logout</a>
<a href="${request.route_path('signup')}">Sign Up</a>
<br>
<h2>Keys</h2>
<a href="${request.route_path('key.add')}">Add Key</a>
<a href="${request.route_path('key.list')}">List Keys</a>

<h3>You are</h3> currently logged in as user: ${user}