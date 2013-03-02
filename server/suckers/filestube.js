// Generated by CoffeeScript 1.4.0
var Filestube, cheerio;

cheerio = __meteor_bootstrap__.require('cheerio');

if (!Filestube) {
  Filestube = {};
}

Filestube.getUrl = function(term, pageNum, uploadedOnly) {
  var i, query, url, word, words, _i, _len;
  words = term.split(' ');
  query = '';
  for (i = _i = 0, _len = words.length; _i < _len; i = ++_i) {
    word = words[i];
    query += word + (i === (words.length - 1) ? '' : '+');
  }
  url = 'http://filestube.com/query.html?q=' + query + '&page=' + pageNum;
  if (uploadedOnly) {
    url += '&hosting=24';
  }
  return url;
};

Filestube.suck = function(term, pageNum, uploadedOnly, callback) {
  var results, url;
  results = [];
  url = Filestube.getUrl(term, pageNum, uploadedOnly);
  return Meteor.http.get(url, function(err, res) {
    var $;
    if (err) {
      return callback(err, null);
    } else if (res.statusCode === 200) {
      $ = cheerio.load(res.content);
      return $('#newresult').each(function() {
        var $a, $div, link, meta, title;
        $a = this.find('.resultsLink');
        link = $a.attr('href');
        title = $a.attr('title');
        $div = this.find('>div').find('>div');
        meta = $div.text();
        if (meta.indexOf('Watch here') < 0) {
          results.push({
            title: title,
            link: link,
            meta: meta,
            pending: true
          });
          return Filestube.collectDownloadLinks(link, function(err, res) {
            var doCallback, result, _i, _len;
            doCallback = true;
            for (_i = 0, _len = results.length; _i < _len; _i++) {
              result = results[_i];
              if (result.link === res.link) {
                result.pending = false;
                result.downloadLinks = res.downloadLinks;
                result.src = res.src;
              } else if (result.pending === true) {
                doCallback = false;
              }
            }
            if (doCallback) {
              return callback(null, results);
            }
          });
        }
      });
    }
  });
};

Filestube.collectDownloadLinks = function(link, callback) {
  var dlLinks;
  dlLinks = '';
  return Meteor.http.get('http://filestube.com' + link, function(err, res) {
    var $, $details, src;
    if (res.statusCode === 200) {
      $ = cheerio.load(res.content);
      dlLinks = $('#copy_paste_links').text();
      src = '';
      $details = $('.file_details_title');
      $details.each(function() {
        var $spans;
        $spans = this.find('span');
        if ($spans.length && $spans.first().text() === 'Link(s) source:') {
          return src = $spans.siblings('div').find('a').text();
        }
      });
    }
    return callback(err, {
      link: link,
      downloadLinks: dlLinks,
      src: src
    });
  });
};
