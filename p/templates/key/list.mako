<%inherit file="../base.mako"/>
<div class="row">
	<div class="span12">
	<h1>Eigene Keys</h1>
	<table>
		<thead>
			<th>#</th>
			<th>Name</th>
			<th>Beschreibung</th>
			<th>Freigegeben für</th>
			<th>Freigeben</th>
		</thead>
		<tbody>
		% for key in keys:
			<tr>
				<td>${loop.index}</td>
				<td>${key.name}</td>
				<td>${key.description}</td> 
				<td>
				% for permission in key.permissions:
					<a class="btn btn-mini btn-danger" 
						href="keys/permission/delete/${key.id}:${permission.user.id}">
						${permission.user.user_name}
						<i class="icon-close"></i>
					</a>
				% endfor
				</td>
				<td>
					<div class="input-append">
						<form action="/keys/key/changepermission/${key.id}" method="POST">
							<input type="hidden" name="key_id" value="${key.id}">
							<input type="hidden" name="key_permission" value="view">
							<input type="text" class="text" name="name_or_email" placeholder="username">
							<input type="submit" name="form.adduserpermission" value="Abschicken" class="btn btn-success">
						</form>
					</div>
				</td>
			</tr>
		% endfor
		</tbody>
	</table>
	<h2>Freigebene Keys</h2>
	% for perm in perms:
		<li>${perm.key.name} 
		% if perm.key.description:
			| ${perm.key.description} 
		% endif 
		</li>
	% endfor
</div>
</div>