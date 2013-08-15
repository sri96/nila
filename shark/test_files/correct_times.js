//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var _i, _j, a;

  a = 5;

  for (_i = 0, _j = 10; _i < _j; _i += 1) {
    (function(n) {
      console.log("The number is " + (a+n) + "");
    }(_i));
  }

  for (_i = 0, _j = 10; _i < _j; _i += 1) {
    console.log("Hello");
  }

  for (_i = 0, _j = 10; _i < _j; _i += 1) {
    (function(n) {
      console.log("The number is " + (n));
      console.log("Twice the number is " + (2*n) + "");
    }(_i));
  }

}).call(this);