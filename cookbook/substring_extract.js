//Written using Nila. Visit http://adhithyan15.github.io/nila
(function() {
  var fruits_i_like, fruits_list, start;

  fruits_i_like = "List of fruits I like:apples, oranges, pineapple and mango";

  start = fruits_i_like.indexOf(":");

  // Indexing Range Method

  fruits_list = fruits_i_like.slice(start+1);

  console.log(fruits_list);

  // Slicing Method

  fruits_list = fruits_i_like.slice(start+1);

  console.log(fruits_list);

}).call(this);