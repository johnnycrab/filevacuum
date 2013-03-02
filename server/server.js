// Generated by CoffeeScript 1.4.0
var FileVacuum, Future;

console.log('restarting server...');

if (!FileVacuum) {
  FileVacuum = {};
}

Future = __meteor_bootstrap__.require('fibers/future');

Meteor.methods({
  searchFilestube: function(term, pageNum, uploadedOnly) {
    var fut;
    console.log('searching for "' + term + '" on filestube...');
    fut = new Future();
    Filestube.suck(term, pageNum, uploadedOnly, function(err, res) {
      return fut.ret(res);
    });
    return fut.wait();
  }
});
