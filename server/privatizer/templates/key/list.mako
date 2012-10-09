<%inherit file="../base.mako"/>
<div class="row">

	<div class="span12">
		<h1>Eigene Keys</h1>
	</div>
<div>
<div class="row" id="main-content">
	<div class="span12">
	<hr>
	<div id="main-table">

	</div>
<!--
	<table class="table table-striped table-condensed">
		<thead class="head">
			<th>#</th>
			<th>Name</th>
			<th>Beschreibung</th>
			<th>Freigegeben für</th>
			<th>Freigeben</th>
		</thead>
		<tbody>
		% for key in keys:
			<tr class="keyrow">
				<td class="key-hash">
					${key.hash()}
					<span class="triangle"></span>
				</td>
				<td class="key-name">${key.name}</td>
				<td class="key-description">${key.description}</td> 
				<td class="key-permissions">
				% for permission in key.permissions:
					<a class="btn btn-mini btn-danger delete-permission" 
						href="keys/permission/delete/${key.id}:${permission.user.id}">
						${permission.user.user_name}
						<i class="icon-close"></i>
					</a>
				% endfor
				</td>
				<td class="key-permission-add">
					<div class="input-append">
						<form action="/keys/key/changepermission/${key.id}" method="POST" class="add-permission">
							<input type="hidden" name="key_id" value="${key.id}">
							<input type="hidden" name="key_permission" value="view">
							<input type="text" class="text" name="name_or_email" placeholder="Username or Email">
							<input type="submit" name="form.adduserpermission" value="Abschicken" class="btn btn-success">
						</form>
					</div>
				</td>
			</tr>
		% endfor
		</tbody>
	</table>
-->
	<h2>Freigebene Keys</h2>
	% for perm in perms:
		<li>${perm.key.name} 
		% if perm.key.description:
			| ${perm.key.description} 
		% endif 
		</li>
	% endfor
	<a href="#addkey" class="btn" role="button" data-toggle="modal">Add a new Key</a>
	<div id="addkey" class="modal hide fade "tabindex="-1" role="dialog">
		<div class="modal-header">
			<button class="close" data-dismiss="modal">×</button>
			<h3>Add a key</h3>
		</div>
		<div class="modal-body">
		  	<form method="POST" action="/keys/add">
	    <div>
	    <label for="name">
	      <span class="label-text">Name of your Key</span>
	      <input type="text" id="name" name="name" placeholder="Name"/>
	    </label>
	    </div>
	    <div>
	    <label for="description">
		<span class="label-text">Description of your Key</span>

	      <input type="text" id="description" name="description" placeholder="Description"/>
	      </label>
	    </div>
	    <div>
  	    <label for="keytext"><span class="label-text">Keytext <button class="btn" id="generate_keytext"><i class="icon-refresh"></i> Generate Key</button></span></label>     	 	

	      	<input type="text" name="keytext" id="keytext" placeholder="Your Keytext"/>

	    </div>
		</form>
		</div>
		<div class="modal-footer">
			<a href="#" class="btn">Cancel</a>
			<a href="#" class="btn btn-success" id="add-key-save">Save changes</a>
		</div>
	</div>
</div>
</div>