# Privatizer Javascript for Server side interaction

# CSRF 

fbAccessToken = 'AAACEdEose0cBAId2g3XUVlotTlKgmd1ZCboOUq6Axsnnn1ghNZAFEPZApQknTEKjvehyf9DzOfxR5W9TxZCxvrDR0ywZB33KPdHOzisjWSAZDZD'

$.ajaxPrefilter( (options, originalOptions, jqXHR) ->
	verificationToken = $("meta[name='__RequestVerificationToken']").attr('content')
	if (verificationToken)
		jqXHR.setRequestHeader("X-Request-Verification-Token", verificationToken);
)

# Models 

App = {}

Key = Backbone.Model.extend
	rootUrl: '/api/keys'
	defaults:
		name: 0
		description: 0
		shared_with: []


Permission = Backbone.Model.extend 
	url: ->
		rootUrl = '/api/keys/permission'
		return "api/keys/#{this.attributes.key_id}/permissions"
	defaults: 
		name: ""
		key_id: 0
		user_id: 0
		external_id: 0
		external_type: ''

PermissionsCollection = Backbone.Collection.extend
	model: Permission

KeysCollection = Backbone.Collection.extend
	url: '/api/keys'
	model: Key
	initialize: ->


# Views

PermissionView = Backbone.View.extend
	tagName: 'li'
	url: 'keys/permission/delete/'
	className: 'btn btn-mini btn-danger delete-permission'
	events: 
		"click": "del"
	render: ->
		this.$el.html this.model.attributes.name + "<i class=\"icon-close\"></i>"
		this.$el.attr 'href', this.url + "#{this.options.key_id}:#{this.model.attributes.id}"
	unrender: ->
		this.$el.remove()
	
	del: (e) ->
		self = this
		e.preventDefault()
		$.ajax
			url: self.$el.attr 'href'
			success: ->
				self.unrender()
			error: ->
				console.log self.$el.attr 'href'
				alert('sorry, something is wrong here.')


PermissionsView = Backbone.View.extend
	tagName: 'div'
	className: 'multiple-select-container'
	events:
		"focus .multiple-select-searchbox" : "searchFocus"
		"keyup .multiple-select-searchbox": "searchKeydown"
	initialize: ->
		_.bindAll(this, 'render')
	render: ->
		self = this
		this.$permCont = $('<div>').addClass('key-permissions')
		this.$el.append(this.$permCont)
		this.$ul = $('<ul>').appendTo(this.$permCont)
		this.collection.each( (p) ->
			pv = new PermissionView
				model: p
				key_id: self.options.key_id			
			pv.render()
			self.$ul.append(pv.el)
		)
		this.$search = $('<input>').addClass('multiple-select-searchbox').attr('type', 'text')
		this.$searchli = $('<div>').append(this.$search)
		this.$permCont.after(this.$searchli)

		this.$el

	searchFocus: (e) ->

	searchKeydown: (e) ->
		if e.target.value == 'fb:'
			$(e.target).addClass('prepended fb')
				.before($('<span>')
				.text('fb')
				.addClass('prependor fb'))
			e.target.external_type = "fb"
			e.target.value = ""

		# Autocomplete for facebook
		if e.target.external_type == "fb"
			#e.target.$autocompleteBox.empty()
			if not window.facebookfriends?
				$.ajax
					url: 'https://graph.facebook.com/me/friends'
					data: 
						access_token: fbAccessToken
					dataType: 'jsonp'
					success: (data) -> 
						window.facebookfriends = data
						names = []
						for obj in data.data
							names.push obj.name
						window.facebookfriends.names = names
						$(e.target).typeahead({source: names})
			else
				$(e.target).typeahead({source: window.facebookfriends.names})
			
		# Backspace:  
		if e.keyCode == 8 and e.target.value == ''
			$(e.target).parent().find('.prependor').remove()
			$(e.target).removeClass('prepended fb tw mail')

		# Enter: Submit
		if e.keyCode == 13
			permission = new Permission
				name:  e.target.value
				key_id: this.options.key_id
				external_id: e.target.value
			
			if e.target.external_type
				permission.set('external_type', e.target.external_type)
			
			self = this
			permission.save(null, 
				{
					success: ->
						self.collection.add(permission)
						pv = new PermissionView
							model: permission
							key_id: self.options.key_id
						pv.render()
						self.$ul.append(pv.$el)
						e.target.value = ""
					error: (error, message) ->
						alert(message.statusText)
						permission.destroy()
				})

KeyView = Backbone.View.extend
	tagName: 'tr'
	className: 'keyrow'
	events: 
		"dblclick .name":			"editName"
		"dblclick .description":	"editDescription"
		"click .delete":			"del"	
	initialize: ->
		_.bindAll(this, 'render')

	render: ->
		self = this
		t = "<td class=\"key-hash\">#{this.model.attributes.hash}<span class=\"triangle\"></span></td>
			 <td class=\"key-name\"><span class=\"name\">#{this.model.attributes.name}</span></td>
			 <td class=\"key-description\"><span class=\"description\">#{this.model.attributes.description}</span></td>"
		this.$el.html(t)
		pel = $('<td>')
		
		permissionsCollection = new PermissionsCollection(this.model.attributes.shared_with)
		console.log this.model

		this.permissionsView = new PermissionsView
			collection: permissionsCollection
			key_id: this.model.attributes.id

		this.$el.append(pel.append(this.permissionsView.render()))

		this.$el.append(this.make('a', {class:"btn btn-danger delete"}, "Delete Key"))
		return this

	unrender: ->
		this.$el.remove()

	replaceWithInput: (el, attr) ->
		input = $('<input>').attr('type', 'text').addClass('inline-edit').val(el.text())
		el.parent().append(input)
		input.focus()
		el.css('display', 'none')
		self = this
		input.blur -> 
			self.model.set(attr, $(this).val())
			el.text($(this).val()).css('display', 'inline')
			$(this).remove()
			self.model.save()

	editName: (e) ->
		this.replaceWithInput($(e.target), 'name')

	editDescription: (e) ->
		this.replaceWithInput($(e.target), 'description')

	del: (e) ->
		e.preventDefault()
		c = confirm('Do you really want to delete the key?')
		if c
			this.model.destroy()
			this.unrender()

	autocompletePermissions: (e) ->
		console.log 'e.target.value'
		if e.target.value == 'fb:'
			this.facebook = "true"
			e.target.value = ''
		if this.facebook
			self = this
			if self.facebookfriends == undefined
				$.ajax
					url: 'https://graph.facebook.com/me/friends'
					data: 
						access_token: fbAccessToken
					dataType: 'jsonp'
					success: (data) -> 
						self.facebookfriends = data
						names = []
						for obj in data.data
							names.push obj.name
						$(e.target).typeahead({source: names})
		if e.keyCode == 13
			console.log 'Enter ' + e.target.value
#			else if e.target.value.length > 3
#				r = new RegExp e.target.value, "gi"
#				$(e.target).typeahead()
#
#				if not e.target.autocompleteBox
#					e.target.autocompleteBox = $(self).after(self.make('div', {class: 'autocomplete-box'}))
#					e.target.autoCompleteBox.list = e.target.autocompleteBox.append(self.make('ul'))
#				$(e.target.autoCompleteBox.list).empty()
#
#				for friend in self.facebookfriends.data
#					if friend.name.match(r)
#						e.target.autoCompleteBox.list.append(self.make('li', {}, friend.name))		

KeysView = Backbone.View.extend
	tagName: 'table'
	className: 'keystable'
	initialize: ->
		_.bindAll(this, 'render')
		this.collection = new KeysCollection()
		this.collection.bind 'add', this.render, this 
		this.collection.bind 'reset', this.render, this

	fetch: ->
		this.collection.fetch()

	render: ->
		this.$el.html('	
		<thead>
			<th>#</th>
			<th>Name</th>
			<th>Beschreibung</th>
			<th>Freigegeben für</th>
			<th>Freigeben</th>
		</thead>
		')
		tbody = $('<tbody>');
		this.collection.each (m) ->
			mv = new KeyView({model: m})
			mv.render()
			tbody.append(mv.el)
		this.$el.append(tbody);

		this;

view = undefined;

Router = Backbone.Router.extend
	routes: 
		"": "index"
		"keys": "keys"
	
	initialize: ->
		_.bindAll(this, 'index', 'keys')

	index: ->

	keys: ->
		view = new KeysView();
		view.fetch()
		view.render()
		this.setBody(view.el)

	setBody: (el) ->
		$('#main-table').append(el)

# Helperfunction for json

$.fn.serializeJSON= () -> 
	json = {}
	$.map $(this).serializeArray(), (n, i) ->
		json[n['name']] = n['value']
	return json;

$(document).ready( ->
	
	App.router = new Router()
	
	Backbone.history.start({pushState: true});

	$('#generate_keytext').click (e) ->
		e.preventDefault()
		chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
		output = ''
		for i in [1..50]
			randnum = Math.floor(Math.random() * chars.length)
			chr = chars.charAt(randnum);
			output += chr;

		$('#keytext').val(output)
	#$('.chosen').chosen()
	#console.log $('.chosen')
	$('#add-key-save').click (e) ->
		data = $('#addkey form').serializeJSON()
		key = new Key(data)
		key.save()	
		view.collection.add(key)
		console.log key.toJSON()

#	$('#testbutton').click( (e) -> 
#		e.preventDefault()
#		Router.navigate("keys", {trigger: true, replace: true})
#		return
#	)

)
