var sb, funcTest, textarea;
sb = new sandbox({
  root: 'iframe'
});
funcTest = function(){
  console.log("[Load] string: 'hello world'");
  return sb.load("Text load from string ( sandbox.load '...' ) OK").then(function(){
    return debounce(2000);
  }).then(function(){
    var config;
    console.log("[Load] object with string");
    config = {
      html: "<html><head></head><body> Load HTML,JS and CSS from Object... <span></span></body></html>",
      js: "console.log(\"[In Sandbox] loaded from object string\");\ndocument.querySelector(\"span\").innerText = \"JS Load OK.\"",
      css: 'html,body { background: #f00; }\nspan:before { content: "CSS Load OK."; display: block; }'
    };
    return sb.load(config);
  }).then(function(){
    return debounce(2000);
  }).then(function(){
    console.log("[Load] object with URL");
    return sb.load({
      html: {
        url: "/sandbox.html"
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
    sb.setProxy({
      Interface: Interface
    });
    return sb.proxy.func();
  }).then(function(){
    return console.log("test completed.");
  });
};
textarea = ld$.find(document, 'textarea', 0);
textarea.addEventListener('keyup', debounce(function(){
  return sb.load(textarea.value);
}));
sb.load(textarea.value);