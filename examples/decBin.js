//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var _i,_j,decimalToBinary;

  //This is Nila's decimal to Binary converter. It's awesome

  decimalToBinary = function(input_num) {
    var remainder, storage, numsplit, inputnum, decimalplaces, calc, decans;
    remainder = "";
    storage = [];
    if (!((input_num.indexOf(".") === -1))) {
      numsplit = input_num.split(".");
      inputnum = Number(numsplit[0]);
      decimalplaces = parseFloat("0." + numsplit[1]);
    } else {
      inputnum = Number(input_num);
      decimalplaces = [];
    }
    while (inputnum >= 1) {
      console.log("2 | " + (inputnum) + " " + (remainder));
      remainder = inputnum%2;
      inputnum = (inputnum-remainder)/2;
      storage.push(remainder);
    }
    storage.reverse();
    if (decimalplaces.toString().length > 0) {
      storage.push(".");
    }
    calc = null;
    decans = null;
    for (_i = 0, _j = decimalplaces.toString().length-2; _i < _j; _i += 1) {
      calc = decimalplaces * 2;
      decans = calc.toString()[0];
      decimalplaces = parseFloat("0." + (calc.toString().slice(2)));
      storage.push(Number(decans));
    };
    return storage;
  };

  process.stdin.resume();

  process.stdin.setEncoding('utf8');

  process.stdin.on('data',function(chunk) {
    process.stdout.write("Answer: " + (decimalToBinary(chunk).join("")) + " \n\n");
  });

}).call(this);