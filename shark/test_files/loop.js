//Written using Nila. Visit http://adhithyan15.github.io/nila
(function () {
  var i;

  loop { puts "Looping forever!" };

  i=0;

  while (true) {
    i+=1;
    process.stdout.write("" + (i) + " ");
    if (i===10) {
      break;
    }
  }

}).call(this);