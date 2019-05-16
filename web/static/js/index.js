// Generated by LiveScript 1.3.1
var sb;
sb = new Sandbox({
  root: 'iframe'
});
console.log("[Load] string: 'hello world'");
sb.load("hello world!").then(function(){
  return debounce(2000);
}).then(function(){
  var config;
  console.log("[Load] object with string");
  config = {
    html: "<html><head></head><body> Hello </body></html>",
    js: "console.log(\"[In Sandbox] loaded from string\");",
    css: 'html,body { background: #f00; }'
  };
  return sb.load(config);
}).then(function(){
  return debounce(2000);
}).then(function(){
  console.log("[Load] object with url");
  return sb.load({
    html: {
      url: "/editor.html"
    }
  });
}).then(function(){
  return debounce(2000);
}).then(function(){
  console.log("[Load] Reload");
  return new Promise(function(res, rej){
    return setTimeout(function(){
      return sb.reload().then(function(){
        return res();
      });
    }, 2000);
  });
}).then(function(){
  console.log("test completed.");
  sb.setProxy({
    Interface: Interface
  });
  return sb.proxy.blah();
});