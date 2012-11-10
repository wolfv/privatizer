<%inherit file="../base.mako"/>
<%block	name="form">
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
	    <hr>
	    <input class="btn btn-primary" type="submit" name="form.submitted" value="Submit"/>
	</form>
</%block>

<hr>
<div class="row"><div class="span12">
	<h1>Add a key to your collection</h1>
	Please, add a key. Why not?
	</div>
</div>
<hr>