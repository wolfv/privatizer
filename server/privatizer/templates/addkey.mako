<%inherit file="base.mako"/>
<%block	name="form">
  	<form method="POST" action="/keys/add">
	    <div>
	    <label for="name">Name of your Key
	      <input type="text" name="name" placeholder="Name"/>
	    </label>
	    </div>
	    <div>
	    <label for="description">Description of your Key
	      <input type="text" name="description" placeholder="Description"/>
	      </label>
	    </div>
	    <div>
  	    <label for="keytext">Keytext</label>
	    <div class="input-append">
	      	<input type="text" name="keytext" id="keytext" placeholder="Your Keytext (generate a save one)"/>

     	 	<button class="btn" id="generate_keytext"><i class="icon-refresh"></i> Generate Key</button>
	      </span>
	    </div>
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