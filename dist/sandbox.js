// Generated by LiveScript 1.3.1
var Sandbox, slice$ = [].slice;
Sandbox = function(opt){
  var root, container, that;
  opt == null && (opt = {});
  this.opt = opt;
  this.proxy = {};
  this.root = root = opt.root ? typeof opt.root === 'string'
    ? document.querySelector(opt.root)
    : opt.root : void 8;
  if (!root) {
    this.root = root = document.createElement("iframe");
  }
  (this.opt.className || '').split(' ').map(function(it){
    return root.classList.add(it);
  });
  this.container = container = (that = root && root.parentNode)
    ? that
    : this.opt.container ? typeof opt.container === 'string'
      ? document.querySelector(opt.container)
      : opt.container : void 8;
  if (!container) {
    this.container = container = document.body;
  }
  if (!this.root.parentNode) {
    container.appendChild(root);
  }
  root.setAttribute('sandbox', opt.sandbox || 'allow-scripts allow-pointer-lock');
  return this;
};
Sandbox.prototype = import$(Object.create(Object.prototype), {
  rpcCode: '<script>\nwindow.addEventListener("message", function(e) {\nif(!e || !e.data || e.data.type != \'rpc\') return;\nwindow[e.data.name][e.data.func](e.data.args);\n}, false);\n</script>',
  send: function(msg){
    return this.root.contentWindow.postMessage({
      type: 'msg',
      payload: msg
    }, '*');
  },
  setProxy: function(obj){
    var k, v, ref$, name, proxy, results$ = [], this$ = this;
    ref$ = (function(){
      var ref$, results$ = [];
      for (k in ref$ = obj) {
        v = ref$[k];
        results$.push([k, v]);
      }
      return results$;
    }())[0], name = ref$[0], obj = ref$[1];
    this.proxy = proxy = {};
    for (k in obj) {
      v = obj[k];
      results$.push(fn$(k, v));
    }
    return results$;
    function fn$(k, v){
      return proxy[k] = function(){
        var args;
        args = slice$.call(arguments);
        return this$.root.contentWindow.postMessage({
          type: 'rpc',
          name: name,
          func: k,
          args: args
        }, '*');
      };
    }
  },
  reload: function(){
    var this$ = this;
    return new Promise(function(res, rej){
      this$.root.onload = function(){
        return res(this$.url);
      };
      return this$.root.src = this$.url;
    });
  },
  load: function(d){
    var promises, this$ = this;
    d == null && (d = "");
    if (typeof d === 'string') {
      return new Promise(function(res, rej){
        var url;
        this$.url = url = URL.createObjectURL(new Blob([d + this$.rpcCode], {
          type: 'text/html'
        }));
        this$.root.onload = function(){
          return res(url);
        };
        return this$.root.src = url;
      });
    }
    promises = ['html', 'css', 'js'].map(function(it){
      return [it, d[it]];
    }).filter(function(it){
      return it[1];
    }).map(function(n){
      if (n[1] && n[1].url) {
        return fetch(n[1].url).then(function(v){
          if (!(v && v.ok)) {
            v.clone().text().then(function(t){
              var e, ref$;
              e = (ref$ = new Error(v.status + " " + t), ref$.data = v, ref$);
              throw e;
            });
          }
          return v.text();
        }).then(function(it){
          return [n[0], it];
        });
      } else {
        return Promise.resolve([n[0], n[1]]);
      }
    });
    return Promise.all(promises).then(function(list){
      var d;
      d = {};
      list.map(function(it){
        return d[it[0]] = it[1];
      });
      return this$.load("" + d.html + "\n<script>\n//<![[CDATA\n" + d.js + "\n//]]>\n</script>\n<style type=\"text/css\">\n/*<![[CDATA*/\n" + d.css + "\n/*]]>*/\n</style>");
    });
  }
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
