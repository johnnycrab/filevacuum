if not FileVacuum then FileVacuum = {}
if not Filestube then Filestube = {}

# ghetto routing
Template.main.hasFileSearch = ->
	if Session.get 'searchterm' then return true else return false

Template.main.hasResults = ->
	if Session.get 'results' then return true else return false

Template.searchform.uploadedOnly = ->
	Session.get 'uploadedOnly'

Template.searchform.term = ->
	results = Session.get 'results'
	if results and results.filestube then return results.filestube.term

Template.filelist.results = ->
	Session.get 'results'

Template.filelist.isntFirst = (obj) ->
	obj.pageNum > 1


FileVacuum.searchFor = (term, pageNum) ->
	pageNum = pageNum || 1
	term = term || Session.get 'searchterm'
	# set session for routing and storing
	Session.set 'searchterm', term
	Session.set 'results', null
	uploadedOnly = Session.get('uploadedOnly')
	console.log 'Searching for: "' + term + '" on page ' + pageNum
	Meteor.call 'searchFilestube', term, pageNum, uploadedOnly, (err, res) =>
		if not err and res.length
			results = Session.get('results') || {}
			results.filestube = 
				pageNum: pageNum
				term: term
			results.filestube.data = res
			Session.set 'results', results
		else
			@.cleanup()



FileVacuum.cleanup = ->
	console.log 'cleaning up...'
	Session.set 'searchterm', null
	Session.set 'results', null


Template.searchform.events =
	'keypress input[name="file"]': (ev) ->
		if ev.keyCode is 13
			term = $(ev.target).val()
			if term then FileVacuum.searchFor term
	'click button.doSearch': (ev) ->
		term = $(ev.target).parent().find('input').val()
		if term then FileVacuum.searchFor term, 1
	'change input[name="ulonly"]': (ev) ->
		Session.set 'uploadedOnly', if $(ev.target).attr 'checked' then true else false


Template.filelist.events =
	'click .downloadLinks': (ev) ->
		$(ev.target).select()
	'click #pagination .prev': (ev) ->
		ev.preventDefault()
		results = Session.get('results')
		FileVacuum.searchFor null, results.filestube.pageNum - 1
		false
	'click #pagination .next': (ev) ->
		ev.preventDefault()
		results = Session.get('results')
		console.log results
		FileVacuum.searchFor null, results.filestube.pageNum + 1
		false
