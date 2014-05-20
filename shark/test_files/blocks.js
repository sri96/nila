//Written using Nila. Visit http://adhithyan15.github.io/nila
(function () {
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

  read.on('close',function() {
    stream.end();
    fs.unlink(file_name,function(err) {
      if (err) {
        console.log(err);
      }
      console.log("REPL Session Successfully concluded!");
    });
    console.log("\n\nThanks for trying out Nila!\n") --single_line_comment
    console.log("You can learn more about Nila at http://adhithyan15.github.io/nila\n");
    process.exit(0);
  });

}).call(this);