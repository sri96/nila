//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var parsed_name;

  // This method demonstrates multiple return values

  function parse_name(input_name) {
    var name_split;
    name_split = input_name.split(" ");
    return [name_split[0],name_split[1]];
  }

  function test_method() {
    return console.log("Hello, Adhithya");
  }

  parsed_name = parse_name("Adhithya Rajasekaran");

}).call(this);