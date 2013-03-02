cheerio = __meteor_bootstrap__.require 'cheerio'

if not Filestube then Filestube = {}

Filestube.getUrl = (term, pageNum, uploadedOnly) ->
	words = term.split(' ')
	query = ''
	for word, i in words
		query += word + if (i == (words.length - 1)) then '' else '+'
	url = 'http://filestube.com/query.html?q=' + query + '&page=' + pageNum
	if uploadedOnly then url += '&hosting=24'
	url

Filestube.suck = (term, pageNum, uploadedOnly, callback) ->
	results = []
	url = Filestube.getUrl term, pageNum, uploadedOnly

	# get the stuff from filestube
	Meteor.http.get url, (err, res) ->
		if err 
			callback err, null
		else if res.statusCode is 200
			$ = cheerio.load res.content
			$('#newresult').each ->
				# putting the results together
				$a = @.find '.resultsLink'
				link = $a.attr 'href'
				title = $a.attr 'title'
				$div = @.find('>div').find('>div')
				meta = $div.text()
				if meta.indexOf('Watch here') < 0
					results.push
						title: title,
						link: link,
						meta: meta
						pending: true
					Filestube.collectDownloadLinks link, (err, res) ->
						doCallback = true
						for result in results
							if result.link is res.link
								result.pending = false
								result.downloadLinks = res.downloadLinks
								result.src = res.src
							else if result.pending is true
								doCallback = false
						if doCallback then callback null, results

Filestube.collectDownloadLinks = (link, callback) ->
	dlLinks = ''
	Meteor.http.get 'http://filestube.com' + link, (err, res) ->
		if res.statusCode is 200
			$ = cheerio.load res.content
			# get the links
			dlLinks = $('#copy_paste_links').text()

			# get the source
			src = ''
			$details = $('.file_details_title')
			$details.each ->
				$spans = @.find 'span'
				if $spans.length and $spans.first().text() is 'Link(s) source:' then src = $spans.siblings('div').find('a').text()
		callback err, 
			link : link
			downloadLinks : dlLinks
			src : src

