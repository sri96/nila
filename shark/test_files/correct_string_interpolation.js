//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var msg;

  //This file tests the limits of the string interpolation feature present in Nila

  msg = "Hello " + ("world. A lovely place.") + "" + "Another " + ("Lovely quote");

  console.log(msg);

  console.log("Hello " + ("world"));

  console.log('Hello #{world}');

  console.log('Hello');

}).call(this);