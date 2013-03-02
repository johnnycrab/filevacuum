console.log 'restarting server...'
if not FileVacuum then FileVacuum = {}

Future = __meteor_bootstrap__.require 'fibers/future'


Meteor.methods
	searchFilestube: (term, pageNum, uploadedOnly) ->
		console.log 'searching for "' + term + '" on filestube...'
		fut = new Future()
		Filestube.suck term, pageNum, uploadedOnly, (err, res) ->
			fut.ret res

		return fut.wait()

