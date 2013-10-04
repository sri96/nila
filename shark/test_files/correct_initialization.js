//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var _ref1, count, current_val, first_name, last_name, next_val, parse_name;

  // This file demonstrates multiple variable initialization

  parse_name = function(input_name) {
    var name_split;
    name_split = input_name.split(" ");
    return [name_split[0],name_split[1]];
  };

  _ref1 = parse_name("Adhithya Rajasekaran");

  first_name = _ref1[0];

  last_name = _ref1[1];

  console.log(first_name + " " + last_name);

  _ref1 = [0, 1, 1];

  current_val = _ref1[0];

  next_val = _ref1[1];

  count = _ref1[2];

}).call(this);