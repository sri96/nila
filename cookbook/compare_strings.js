//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var input_name;

  input_name = prompt("What is your name?");

  if (input_name === "Jim") {
    alert("Hey Jim!");
  } else {
    alert("Hey " + (input_name));
  }

}).call(this);