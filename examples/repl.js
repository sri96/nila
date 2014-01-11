//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var file_name, fs, read, readline, rl, stream;

  // This is a small REPL for Nila to test out nila code and do bug fixes

  readline = require('readline');

  fs = require('fs');

  file_name = "" + (__dirname) + "/my_file.nila";

  stream = fs.createWriteStream(file_name);

  stream.once('open',function(fd) {
    stream.write("# REPL Session " + (new Date().toString()));
  });

  rl = readline.createInterface(process.stdin, process.stdout);

  rl.setPrompt('nila> ');

  rl.prompt();

  read = rl.on('line',function(line) {
    stream.write(line);
    rl.prompt();
  });

  read.on('close',function() {
    stream.end();
    fs.unlink(file_name,function(err) {
      if (err) {
        console.log(err);
      }
      console.log("REPL Session Successfully concluded!");
    });
    console.log("\n\nThanks for trying out Nila!\n")
    console.log("You can learn more about Nila at http://adhithyan15.github.io/nila\n");
    process.exit(0);
  });

}).call(this);