//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var msg, number, x;

  //This file tests the limits of the string interpolation feature present in Nila

  number = 5;

  msg = "Hello " + ("world. A lovely place.") + "" + "Another " + ("Lovely quote");

  console.log(msg);

  console.log("Hello " + ("world"));

  console.log('Hello #{world}');

  console.log('Hello');

  console.log("We're #" + (number) + "!");

  console.log("I've set x to " + (x = 5, x += 1) + ".");

}).call(this);