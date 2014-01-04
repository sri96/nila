//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var _i, _j, grade, grades, num;

  grades = ["A", "B", "A", "C", "D", "F"];

  for (_i = 0, _j = grades.length; _i < _j; _i += 1) {
    grade = grades[_i];
    switch(grade) {
      case "A":
        console.log('You are pretty smart!');
        break;
      case "B":
        console.log('You are pretty smart!');
        break;
      case "C":
        console.log('You are reasonably intelligent!');
        break;
    }
  }

  num = 5;

  switch(num) {
    case 1:
      console.log('Your input was 1');
      break;
    case 2:
      console.log('Your input was 2');
      break;
    default:
      console.log("Your input was greater than 2");
  }

}).call(this);