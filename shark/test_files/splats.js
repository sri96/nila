//Written using Nila. Visit http://adhithyan15.github.io/nila
(function () {
  var args_unleashed, default_args, mixed_args, two_or_more;

  // These example were taken from The Well Grounded Rubyist by Manning
  // Copyright: Manning Publications

  two_or_more = function() {
    var a, b, c;
    a = arguments[0];
    b = arguments[1];
    c = [];
    for (var i=2;i<arguments.length;i++) {
      c.push(arguments[i]);
    }
    console.log("I require two or more arguments!");
    console.log("And sure enough, I got: ");
    console.log(a);
    console.log(b);
    return console.log(c);
  };

  two_or_more 1,2,3,4,5;

  default_args = function(a,b,c) {
    if (c == null) {
      c = 1;
    }
    console.log("Values of variables: ");
    console.log(a);
    console.log(b);
    return console.log(c);
  };

  default_args 3,2;

  default_args 4,5,6;

  mixed_args = function() {
    var a, b, c, d, e, f;
    a = arguments[0];
    b = arguments[1];
    c = arguments[2];
    e = arguments[arguments.length-2];
    f = arguments[arguments.length-1];
    d = [];
    for (var i=3;i < arguments.length-2;i++) {
      d.push(arguments[i]);
    }
    console.log("Arguments:");
    console.log(a);
    console.log(b);
    console.log(c);
    console.log(d);
    console.log(e);
    return console.log(f);
  };

  mixed_args(0,1,2,3,4,5,6,7,8);

  args_unleashed = function() {
    var a, b, c, d, e;
    a = arguments[0];
    b = arguments[1];
    d = arguments[arguments.length-2];
    e = arguments[arguments.length-1];
    c = [];
    for (var i=2;i < arguments.length-2;i++) {
      c.push(arguments[i]);
    }
    if (b == null) {
      b=1;
    }
    console.log("Arguments:");
    console.log(a);
    console.log(b);
    console.log(c);
    console.log(d);
    return console.log(e);
  };

  args_unleashed(1,2,3,4,5);

  args_unleashed(1,2,3,4);

  args_unleashed(1,2,3,4,5,6,7,8);

}).call(this);