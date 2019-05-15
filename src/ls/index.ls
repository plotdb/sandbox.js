Sandbox = (opt = {}) ->
  @ <<< opt: opt, proxy: {}
  @root = root = if opt.root =>
    if typeof(opt.root) == \string => document.querySelector(opt.root) else opt.root
  if !root => @root = root = document.createElement("iframe")
  @container = container = if root and root.parentNode => that else if @opt.container =>
    if typeof(opt.container) == \string => document.querySelector(opt.container) else opt.container
  if !container => @container = container = document.body
  if !@root.parentNode => container.appendChild root
  # NOTE: blob iframe in firefox can read host cookie if sandbox is not specified.
  root.setAttribute \sandbox, (opt.sandbox or 'allow-scripts allow-pointer-lock')
  @

Sandbox.prototype = Object.create(Object.prototype) <<< do
  rpc-code: '''
  <script>
  window.addEventListener("message", function(e) {
  if(!e || !e.data || e.data.type != 'rpc') return;
  window[e.data.name][e.data.func](e.data.args);
  }, false);
  </script>
  '''
  send: (msg) -> @root.contentWindow.postMessage {type: \msg, payload: msg}, \*
  set-proxy: (obj) ->
    [name,obj] = [[k,v] for k,v of obj].0
    @proxy = proxy = {}
    for k,v of obj =>
      ((k, v) ~> proxy[k] = (... args) ~>
        @root.contentWindow.postMessage {type: \rpc, name: name, func: k, args: args}, \*
      ) k, v
  reload: -> new Promise (res, rej) ~>
    @root.onload = ~> res @url
    @root.src = @url
  load: (payload) -> new Promise (res, rej) ~>
    @url = url = URL.createObjectURL(new Blob([payload + @rpc-code], {type: \text/html}))
    @root.onload = -> res url
    @root.src = url

  load-url: (d) ->
    promises = <[html css js]>
      .map -> [it, d[it]]
      .filter -> it.1
      .map (n) ->
        fetch n.1
          .then (v) ->
            if !(v and v.ok) => v.clone!text!then (t) -> e = new Error("#{v.status} #t") <<< {data: v}; throw e
            v.text!
          .then -> [n.0, it]
    Promise.all promises
      .then (list) ~>
        payload = {}
        list.map -> payload[it.0] = it.1
        @load-hcj payload



  load-hcj: (d) ->
    @load(
      """
      #{d.html}
      <script>
      //<![[CDATA
      #{d.js}
      //]]>
      </script>
      <style type="text/css">
      /*<![[CDATA*/
      #{d.css}
      /*]]>*/
      </style>
      """
    )

  
sb = new Sandbox root: \iframe

sb.load-url html: "/editor.html"
  .then ->
    console.log \loaded.
    sb.send {act: \test, msg: \detail}
    new Promise (res, rej) ->
      setTimeout (->
        config = do
          html: "<html><head></head><body> Hello </body></html>"
          js: """console.log("hello world!");"""
          css: '''html,body { background: #f00; }'''
        sb.load-hcj config
          .then -> res!
      ), 0
  .then -> sb.load-url html: "/editor.html"
  .then ->
    new Promise (res, rej) ->
      setTimeout (-> sb.reload!then -> res! ), 1000
  .then ->
    console.log \done.
    sb.set-proxy {Interface}
    sb.proxy.blah!
