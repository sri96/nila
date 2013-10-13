//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var commandline_args, parse_markdown;

  // Marky is a simple markdown parser written in Nila and runs on Nodejs. 

  // This will demonstrate the power and expressiveness of Nila. We will also 

  // provide the Ruby version of the parser so that you can see how easy it

  // is to port code from Ruby to Javascript using Nila

  // This parser was written by Sri Madhavi Rajasekaran and is released under

  // the MIT License.

  // If you want to learn more about Nila, please visit http://adhithyan15.github.io/nila

  parse_markdown = function() {
  };

  commandline_args = [];

  process.argv.forEach(function(val,index,array) {
    commandline_args.push(val);
  });

  console.log(commandline_args.slice(2));

}).call(this);