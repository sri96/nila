//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var _i, _j, _ref1, fruit, fruits, x;

  _ref1 = [1,2,3,4];

  for (_i = 0, _j = _ref1.length; _i < _j; _i += 1) {
    x = _ref1[_i];
    console.log(x);
  }

  for (x = 0, _j = 5; x <= _j; x += 1) {
    console.log(x);
  }

  for (x = 0, _j = 5; x < _j; x += 1) {
    console.log(x);
  }

  fruits = ['Apple','Banana', 'Mango'];

  for (_i = 0, _j = fruits.length; _i < _j; _i += 1) {
    fruit = fruits[_i];
    console.log(fruit);
  }

}).call(this);