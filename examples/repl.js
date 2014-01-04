//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var read, readline, rl, stream;

  // This is a small REPL for Nila to test out nila code and do bug fixes

  readline = require('readline');

  require('fs');

  stream = fs.createWriteStream("my_file.nila");

  stream.once('open',function(fd) {
    stream.write("Testing!\n");
    stream.;
  });

  rl = readline.createInterface(process.stdin, process.stdout);

  rl.setPrompt('nila> ');

  rl.prompt();

  read = rl.on('line',function(line) {
    rl.prompt();
  });

  read.on('close',function() {
    console.log("Have a great day!");
    process.exit(0);
  });

}).call(this);