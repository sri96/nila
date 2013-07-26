//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var parsed_name;

  // This method demonstrates multiple return values

  function parse_name(input_name) {
    var _ref1, first_name, last_name;
    _ref1 = input_name.split(" ");
    first_name = _ref1[0];
    last_name = _ref1[1];
    return [first_name,last_name];
  }

  function test_method() {
    return console.log("Hello, Adhithya");
  }

  parsed_name = parse_name("Adhithya Rajasekaran");

}).call(this);