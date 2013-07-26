//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var _ref1, first_name, last_name;

  // This file demonstrates multiple variable initialization

  function parse_name(input_name) {
    var name_split;
    name_split = input_name.split(" ");
    return [name_split[0],name_split[1]];
  }

  _ref1 = parse_name("Adhithya Rajasekaran");

  first_name = _ref1[0];

  last_name = _ref1[1];

  console.log(first_name + " " + last_name);

}).call(this);