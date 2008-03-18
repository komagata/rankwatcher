if (typeof Widget == 'undefined') Widget = {}
if (typeof Widget.Dialog == 'undefined') Widget.Dialog = {}

Widget.Dialog.VERSION = '0.03';

Widget.Dialog = function(opt) {/*{{{*/
  var self = this
  this.id = (new Date).getTime()
  this.opt = (function(d,s){for(var p in s)d[p]=s[p];return d})({
    'overlay': false,
    'dropshadow': true,
    'opacity': 0.5,
    'height': 100,
    'width': 200,
    'okText': 'OK',
    'cancelText': 'Cancel',
    'onOk': function() { self.close() },
    'onCancel': function() { self.close() },
    'onLoading': function() {}
  }, opt || {})
}/*}}}*/

Widget.Dialog.window = function(content, opt) {/*{{{*/
  var dialog = new Widget.Dialog
  dialog.window(content, opt)
  return dialog
}/*}}}*/

Widget.Dialog.remote = function(url, opt) {/*{{{*/
  var dialog = new Widget.Dialog
  dialog.remote(url, opt)
  return dialog
}/*}}}*/

Widget.Dialog.alert = function(msg, opt) {/*{{{*/
  var dialog = new Widget.Dialog
  dialog.alert(msg, opt)
  return dialog
}/*}}}*/

Widget.Dialog.confirm = function(msg, opt) {/*{{{*/
  var dialog = new Widget.Dialog
  dialog.confirm(msg, opt)
  return dialog
}/*}}}*/

Widget.Dialog.prompt = function(msg, opt) {/*{{{*/
  var dialog = new Widget.Dialog
  dialog.prompt(msg, opt)
  return dialog
}/*}}}*/

Widget.Dialog.prototype.window = function(content, opt) {/*{{{*/
  var opt = (function(d,s){for(var p in s)d[p]=s[p];return d})(this.opt, opt || {})
  var dwindow = this._dwindow(opt.height, opt.width)

  if (typeof content == 'string') {
    dwindow.innerHTML = content
  } else {
    dwindow.appendChild(content)
  }

  if (opt.overlay) document.body.appendChild(this._doverlay());
  if (opt.dropshadow) document.body.appendChild(this._dshadow(opt.height, opt.width));
  document.body.appendChild(dwindow);
  return this
}/*}}}*/

Widget.Dialog.prototype.remote = function(url, opt) {/*{{{*/
  var opt = (function(d,s){for(var p in s)d[p]=s[p];return d})(this.opt, opt || {})
  var dwindow = this._dwindow(opt.height, opt.width)
  this._update(url, dwindow)
  if (opt.overlay) document.body.appendChild(this._doverlay());
  if (opt.dropshadow) document.body.appendChild(this._dshadow(opt.height, opt.width));
  document.body.appendChild(dwindow);
  return this
}/*}}}*/

Widget.Dialog.prototype.alert = function(msg, opt) {/*{{{*/
  var opt = (function(d,s){for(var p in s)d[p]=s[p];return d})(this.opt, opt || {})
  var dwindow = this._dwindow(opt.height, opt.width)
  dwindow.appendChild(this._dmsg(msg))
  dwindow.appendChild(this._dbuttonOk(opt.okText, opt.onOk));
  if (opt.overlay) document.body.appendChild(this._doverlay());
  if (opt.dropshadow) document.body.appendChild(this._dshadow(opt.height, opt.width));
  document.body.appendChild(dwindow);
  document.getElementById('dbutton_ok').focus()
  return this
}/*}}}*/

Widget.Dialog.prototype.confirm = function(msg, opt) {/*{{{*/
  var opt = (function(d,s){for(var p in s)d[p]=s[p];return d})(this.opt, opt || {})
  var dwindow = this._dwindow(opt.height, opt.width)
  dwindow.appendChild(this._dmsg(msg))
  dwindow.appendChild(this._dbuttons(opt))
  if (opt.overlay) document.body.appendChild(this._doverlay());
  if (opt.dropshadow) document.body.appendChild(this._dshadow(opt.height, opt.width));
  document.body.appendChild(dwindow);
  document.getElementById('dbutton_ok').focus()
  return this
}/*}}}*/

Widget.Dialog.prototype.prompt = function(msg, opt) {/*{{{*/
  var opt = (function(d,s){for(var p in s)d[p]=s[p];return d})(this.opt, opt || {})
  var dwindow = this._dwindow(opt.height, opt.width)
  dwindow.appendChild(this._dmsg(msg))
  dwindow.appendChild(this._dinput())
  dwindow.appendChild(this._dbuttons(opt))
  if (opt.overlay) document.body.appendChild(this._doverlay());
  if (opt.dropshadow) document.body.appendChild(this._dshadow(opt.height, opt.width));
  document.body.appendChild(dwindow);
  document.getElementById('dinput').focus()
  return this
}/*}}}*/

Widget.Dialog.prototype.close = function() {/*{{{*/
  if (this.opt.overlay) document.body.removeChild(document.getElementById('doverlay_'+this.id))
  if (this.opt.dropshadow) document.body.removeChild(document.getElementById('dshadow'+this.id))
  document.body.removeChild(document.getElementById('dwindow_'+this.id))
  return this
}/*}}}*/

Widget.Dialog.prototype._doverlay = function() {/*{{{*/
  var doverlay = document.createElement('div')
  doverlay.id = 'doverlay_'+this.id
  doverlay.className = 'doverlay'
  with(doverlay.style) {
    top = '0px'
    left = '0px'
    position = 'absolute'
    background = '#000'
  }

  this._setOpacity(doverlay, this.opt.opacity);

  var yScroll = (function(){if(window.innerHeight && window.scrollMaxY){return window.innerHeight + window.scrollMaxY}else if(document.body.scrollHeight > document.body.offsetHeight){return document.body.scrollHeight}else{return document.body.offsetHeight}})()

  var xScroll = (function(){if(window.innerHeight && window.scrollMaxY){return document.body.scrollWidth}else if(document.body.scrollHeight > document.body.offsetHeight){return document.body.scrollWidth}else{return document.body.offsetWidth}})()

  doverlay.style.height = yScroll+'px'
  doverlay.style.width = xScroll+'px'
  return doverlay
}/*}}}*/

Widget.Dialog.prototype._dwindow = function(height, width) {/*{{{*/
  var dwindow = document.createElement('div')
  dwindow.id = 'dwindow_'+this.id
  dwindow.className = 'dwindow'
  var pageSize = this._getPageSize()
  var pos = this._realOffset(document.body)
  dwindow.style.top = (pageSize.windowHeight/2 - height/2 + pos[1])+'px'
  dwindow.style.left = (pageSize.windowWidth/2 - width/2 + pos[0])+'px'
  dwindow.style.height = height+'px'
  dwindow.style.width = width+'px'
  dwindow.style.padding = '10px'
  dwindow.style.border = 'solid 1px #000'
  dwindow.style.backgroundColor = '#fff'
  dwindow.style.position = 'absolute'
  dwindow.style.textAlign = 'center'
  dwindow.style.zindex = '2'
  return dwindow
}/*}}}*/

Widget.Dialog.prototype._dshadow = function(height, width, distance) {/*{{{*/
  var distance = distance || 3
  var dshadow = this._dwindow(height, width)
  dshadow.id = 'dshadow'+this.id
  dshadow.className = 'dshadow'
  dshadow.style.background = '#000'
  dshadow.style.top = (Number(dshadow.style.top.replace(/px$/, '')) + distance) + 'px'
  dshadow.style.left = (Number(dshadow.style.left.replace(/px$/, '')) + distance) + 'px'
  this._setOpacity(dshadow, 0.3);
  return dshadow
}/*}}}*/

Widget.Dialog.prototype._dinput = function() {/*{{{*/
  var dinput = document.createElement('input')
  dinput.id = 'dinput'
  return dinput
}/*}}}*/

Widget.Dialog.prototype._dmsg = function(msg) {/*{{{*/
  var dmsg = document.createElement('div')
  dmsg.className = 'dmsg'
  dmsg.style.padding = '8px'
  dmsg.innerHTML = msg
  return dmsg
}/*}}}*/

Widget.Dialog.prototype._dbuttonOk = function(text, func) {/*{{{*/
  var dbuttonOk = document.createElement('button')
  dbuttonOk.id = 'dbutton_ok'
  dbuttonOk.className = 'dbutton'
  dbuttonOk.appendChild(document.createTextNode(text))
  dbuttonOk.onclick = func
  return dbuttonOk
}/*}}}*/

Widget.Dialog.prototype._dbuttonCancel = function(text, func) {/*{{{*/
  var dbuttonCancel = document.createElement('button')
  dbuttonCancel.id = 'dbutton_cancel'
  dbuttonCancel.className = 'dbutton'
  dbuttonCancel.appendChild(document.createTextNode(text))
  dbuttonCancel.onclick = func
  return dbuttonCancel
}/*}}}*/

Widget.Dialog.prototype._dbuttons = function(opt) {/*{{{*/
  var dbuttons = document.createElement('div')
  dbuttons.id = 'dbuttons'
  dbuttons.style.padding = '6px'
  dbuttons.appendChild(this._dbuttonOk(opt.okText, opt.onOk))
  dbuttons.appendChild(this._dbuttonCancel(opt.cancelText, opt.onCancel))
  return dbuttons
}/*}}}*/

Widget.Dialog.prototype._realOffset = function(element) {/*{{{*/
  var valueT = 0, valueL = 0
  do {
    valueT += element.scrollTop  || 0
    valueL += element.scrollLeft || 0
    element = element.parentNode;
  } while (element)
  return [valueL, valueT]
}/*}}}*/

Widget.Dialog.prototype._setOpacity = function(e,v) {
  if(typeof e=='string')e=document.getElementById(e);if(v==1){e.style.opacity=(/Gecko/.test(navigator.userAgent)&&!/Konqueror|Safari|KHTML/.test(navigator.userAgent))?0.999999:1.0;if(/MSIE/.test(navigator.userAgent) && !window.opera)e.style.filter=e.style.filter.replace(/alpha\([^\)]*\)/gi,'');}else{if(v<0.00001)v=0;e.style.opacity=v;if(/MSIE/.test(navigator.userAgent) && !window.opera)e.style.filter=e.style.filter.replace(/alpha\([^\)]*\)/gi,'')+'alpha(opacity='+v*100+')';}return e;
}

Widget.Dialog.prototype._getPageSize = function() {/*{{{*/
  var xScroll, yScroll;
  if (window.innerHeight && window.scrollMaxY) {
    xScroll = document.body.scrollWidth;
    yScroll = window.innerHeight + window.scrollMaxY;
  } else if (document.body.scrollHeight > document.body.offsetHeight){
    // all but Explorer Mac
    xScroll = document.body.scrollWidth;
    yScroll = document.body.scrollHeight;
  } else {
    // Explorer Mac...would also work in Explorer 6 Strict,
    // Mozilla and Safari
    xScroll = document.body.offsetWidth;
    yScroll = document.body.offsetHeight;
  }

  var windowWidth, windowHeight;
  if (self.innerHeight) {      // all except Explorer
    windowWidth = self.innerWidth;
    windowHeight = self.innerHeight;
  } else if (document.documentElement
  && document.documentElement.clientHeight) {
    // Explorer 6 Strict Mode
    windowWidth = document.documentElement.clientWidth;
    windowHeight = document.documentElement.clientHeight;
  } else if (document.body) { // other Explorers
    windowWidth = document.body.clientWidth;
    windowHeight = document.body.clientHeight;
  }

  // for small pages with total height less then height of the viewport
  if(yScroll < windowHeight){
    pageHeight = windowHeight;
  } else {
    pageHeight = yScroll;
  }

  // for small pages with total width less then width of the viewport
  if(xScroll < windowWidth){
    pageWidth = windowWidth;
  } else {
    pageWidth = xScroll;
  }

  return {
    'pageWidth':pageWidth,
    'pageHeight':pageHeight,
    'windowWidth':windowWidth,
    'windowHeight':windowHeight,
    'yScroll':yScroll,
    'xScroll':xScroll
  }
}/*}}}*/

Widget.Dialog.prototype._xhr = function() {/*{{{*/
  try {
    return new ActiveXObject('Msxml2.XMLHTTP')
  } catch(e) {
    try {
      return new ActiveXObject('Microsoft.XMLHTTP')
    } catch(e) {
      return new XMLHttpRequest()
    }
  }
}/*}}}*/

Widget.Dialog.prototype._send = function(u, f, m, a) {/*{{{*/
  var x = this._xhr()
  x.open(m, u, true)
  x.onreadystatechange = function() {
    if (x.readyState==4) f(x.responseText)
  }
  if(m == 'POST') x.setRequestHeader('Content-type','application/x-www-form-urlencoded')
  x.send(a)
}/*}}}*/

Widget.Dialog.prototype._get = function(url, func) {/*{{{*/
  this._send(url, func, 'GET')
}/*}}}*/

Widget.Dialog.prototype._gets = function(url) {/*{{{*/
  var x = this._xhr()
  x.open('GET', url, false)
  x.send(null)
  return x.responseText
}/*}}}*/

Widget.Dialog.prototype._update = function(url, elm) {
  var e = typeof elm == 'string' ? document.getElementById(elm) : elm
  var f = function(r) { e.innerHTML = r }
  this._get(url, f)
}
