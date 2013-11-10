//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var commandline_args, file_name, fs, parse_markdown, parsed_args;

  // Marky is a simple markdown parser written in Nila and runs on Nodejs. 

  // This will demonstrate the power and expressiveness of Nila. We will also 

  // provide the Ruby version of the parser so that you can see how easy it

  // is to port code from Ruby to Javascript using Nila

  // This parser was written by Sri Madhavi Rajasekaran and is released under

  // the MIT License.

  // If you want to learn more about Nila, please visit http://adhithyan15.github.io/nila

  fs = require('fs');

  parse_markdown = function(input_file) {
    fs.readFile(input_file, 'utf8',function(err,data) {
      if (err) {
        console.log(err);
      }
      console.log(data);
    });
  };

  commandline_args = [];

  process.argv.forEach(function(val,index,array) {
    commandline_args.push(val);
  });

  parsed_args = commandline_args.slice(2);

  if (!(parsed_args.length === 0)) {
    if (parsed_args[0].indexOf("-c") !== -1){    
      file_name = parsed_args[1];
      if (!((typeof file_name === "undefined"))) {
        parse_markdown(file_name);
      } else {
        console.log("No file has been specified!");
      }
    }
  }

}).call(this);