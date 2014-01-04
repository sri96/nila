//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var read;

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

  process.argv.forEach(function(val,index,array) {
    commandline_args.push(val);
  });

}).call(this);