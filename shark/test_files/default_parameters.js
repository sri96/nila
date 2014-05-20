//Written using Nila. Visit http://adhithyan15.github.io/nila
(function () {
  var fill;

  // This is a demo of default parameters

  fill = function(container,liquid) {
    if (container == null) {
      container = "cup";
    }
    if (liquid == null) {
      liquid = "coffee";
    }
    return console.log("Filling " + (container) + " with " + (liquid));
  };

  fill();

  fill("cup");

  fill("bowl","soup");

}).call(this);