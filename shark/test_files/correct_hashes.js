//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var inst_section, student_ages, variable;

  // This file demonstrates several Hash features in Nila

  variable = 5;

  inst_section = {
    cello: 'string',
    clarinet: 'woodwind',
    drum: 'percussion',
    oboe: 'woodwind',
    trumpet: 'brass',
    violin: 'string',
    guitar: 'string',
  };

  if (variable === 10) {
    process.stdout.write("Variable is 10");
  } else if (variable === 20) {
    process.stdout.write("Variable is 20");
  } else {
    process.stdout.write("Variable is something else")
  }

  student_ages = {
    Jack: 10,
    Jill: 12,
    Bob: 14,
  };

}).call(this);