//Written using Nila. Visit http://adhithyan15.github.io/nila
(function () {
  var ATTACHMENT, Evented, Shepherd, _ref, addClass, createFromHTML, extend, getBounds, hasClass, removeClass, uniqueId;

  // A port of Shepard.js project by Hubspot into Nila

  _ref = Tether.Utils;

  extend = _ref.extend;

  removeClass = _ref.removeClass;

  addClass = _ref.addClass;

  hasClass = _ref.hasClass;

  Evented = _ref.Evented;

  getBounds = _ref.getBounds;

  uniqueId = _ref.uniqueId;

  Shepherd = new Evented;

  Shepherd.view = test;

  ATTACHMENT = {
    top: 'bottom center',
    left: 'middle right',
    right: 'middle left',
    bottom: 'top center',
  };

  createFromHTML = function(html) {
    var el;
    el = document.createElement('div');
    el.innerHTML = html;
    return el.children[0];
  };

}).call(this);