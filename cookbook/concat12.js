//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var bool1, string1, string2;

  // Javascript approach

  string1 = "Trust Jim: ";

  bool1 = true;

  string2 = string1 + bool1;

  console.log(string2);

  // Ruby approach

  bool1 = true;

  string2 = "Trust Jim: " + (bool1);

  console.log(string2);

}).call(this);