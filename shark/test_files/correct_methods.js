//Written using Nila. Visit http://adhithyan15.github.io/nila
(function () {
  var createFromHTML;

  createFromHTML = function(html) {
    var el;
    el = document.createElement('div');
    el.innerHTML = html;
    return el.children[0];
  };

}).call(this);