//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var first_name, last_name, multipleinit1;

  // This file demonstrates multiple variable initialization

  function parse_name(input_name) {
    var name_split;
    name_split = input_name.split(" ");
    return [name_split[0],name_split[1]];
  }

  multipleinit1 = parse_name("Adhithya Rajasekaran");

  first_name = multipleinit1[0];

  last_name = multipleinit1[1];

  console.log(first_name + " " + last_name);

}).call(this);