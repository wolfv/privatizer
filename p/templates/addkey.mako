<%inherit file="base.mako"/>
<%block	name="form">  	
  	<form method="POST" action="/keys/add">
	    <div>
	      <input type="text" name="name"/>
	    </div>
	    <div>
	      <input type="text" name="description"/>
	    </div>
	    <input type="submit" name="form.submitted" value="Submit"/>
	</form>
</%block>