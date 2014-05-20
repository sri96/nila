//Written using Nila. Visit http://adhithyan15.github.io/nila
(function () {
  var a, line;

  a = Math.pow(2,3);

  if (a === 8) {
    console.log("Correct Calculation!");
  }

  line = "My favorite language is Ruby!";

  if (line = line.match(/Ruby|Python/)) {
    console.log("Scripting language mentioned: " + (line));
  }

}).call(this);