//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var jsonp, jsonprint, name, parsejson;

  name = "Adhithya Rajasekaran      ".replace(/\s+$/g,"");

  console.log(name);

  name = "    Adhithya Rajasekaran".replace(/^\s+/g,"");

  console.log(name);

  name = "Adhithya Rajasekaran".split(" ");

  console.log(name);

  name = "   Adhithya Rajasekaran  ".replace(/^\s+|\s+$/g,'');

  console.log(name);

  name = "Adhithya,Rajasekaran".split(",");

  console.log(name);

  name = ["Adhithya","Rajasekaran"].join();

  console.log(name);

  jsonprint = function(inputjson) {
    return console.log(inputjson);
  };

  jsonp = function(inputjson) {
    return console.log(inputjson);
  };

  parsejson = function(inputtext) {
    return inputtext.split("{");
  };

  parsejson(jsonprint("{message:Hello World!}"));

  jsonprint("{message:Hello World!}");

}).call(this);