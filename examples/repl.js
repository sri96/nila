//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var read, readline, rl;

  // This is a small REPL for Nila to test out nila code and do bug fixes

  readline = require('readline');

  rl = readline.createInterface(process.stdin, process.stdout);

  rl.setPrompt('nila> ');

  rl.prompt();

  read = rl.on('line',function(line) {
    switch(line.trim()) {
      case 'hello':
        console.log("world!");
        break;
      default:
        console.log("Say what? I might have heard " + (line.trim()));
    }
    rl.prompt();
  });

  read.on('close',function() {
    console.log("Have a great day!");
    process.exit(0);
  });

}).call(this);