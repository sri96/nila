//Written using Nila. Visit http://adhithyan15.github.io/nila
(function () {
  var find_string, main_string;

  main_string = "This is a test string";

  find_string = "test";

  if (main_string.indexOf(find_string) !== -1){
    console.log("Substring found!");
  }

  //=> Substring found!

}).call(this);