//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var avg, nums, sum;

  Array.prototype.sum = function() {
    var val;
    val = 0;
    for (i = 0, _j = this.length-1; i <= _j; i += 1) {
      val += this[i];
    }
    return val;
  };

  Array.prototype.avg = function() {
    return this.sum()/this.length;
  };

  nums = [1,2,3,4,5];

  console.log(nums.sum());

  console.log(nums.avg());

}).call(this);