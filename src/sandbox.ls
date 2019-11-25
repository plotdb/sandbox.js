Sandbox = (opt = {}) ->
  @ <<< opt: opt, proxy: {}

  @root = root = if opt.root =>
    if typeof(opt.root) == \string => document.querySelector(opt.root) else opt.root
  @container = container = if root and root.parentNode => that else if @opt.container =>
    if typeof(opt.container) == \string => document.querySelector(opt.container) else opt.container
  if !container => container = @container = null #container = document.body
  if @container =>
    if !root => @root = root = document.createElement("iframe")
    if !@root.parentNode => container.appendChild root
    # NOTE: blob iframe in firefox can read host cookie if sandbox is not specified.
    root.setAttribute \sandbox, (opt.sandbox or 'allow-scripts allow-pointer-lock')
    (@opt.className or '').split(' ').map -> root.classList.add it
  if wopt = opt.window => @open-window wopt
  @

Sandbox.prototype = Object.create(Object.prototype) <<< do
  rpc-code: '''
  <script>
  window.addEventListener("message", function(e) {
  if(e.data.type == 'load') {
    window.location.href = URL.createObjectURL(new Blob([e.data.args.content], {type: 'text/html'}));
    return;
  }
  if(!e || !e.data || e.data.type != 'rpc') return;
  window[e.data.name][e.data.func](e.data.args);
  }, false);
  </script>
  '''
  open-window: (wopt = {}) -> new Promise (res, rej) ~>
    if !wopt.name => wopt.name = "sandboxjs-#{Math.random!toString 36 .substring 2}"
    url = URL.createObjectURL(new Blob([@rpc-code], {type: \text/html}))
    @window = window.open(url,wopt.name,"width=#{wopt.width or 480},height=#{wopt.height or 640}")
    @opt.window = wopt
    @window.onload = -> res!

  send: (msg) ->
    [@window, (if @root => @root.contentWindow else null)].map ->
      if it => it.postMessage {type: \msg, payload: msg}, \*
  set-proxy: (obj) ->
    [name,obj] = [[k,v] for k,v of obj].0
    @proxy = proxy = {}
    for k,v of obj =>
      ((k, v) ~> proxy[k] = (... args) ~>
        [@window, (if @root => @root.contentWindow else null)].map ->
          if it => it.postMessage {type: \rpc, name: name, func: k, args: args}, \*
      ) k, v
  reload: -> new Promise (res, rej) ~>
    if @root => @root <<< onload: (~> res @url), src: @url
    if @opt.window => @window.postMessage {type: \load, args: {url: @url, content: @content} }

  load: (d="") ->
    if typeof(d) == \string => return new Promise (res, rej) ~>
      @content = (d + @rpc-code)
      @url = url = URL.createObjectURL(new Blob([d + @rpc-code], {type: \text/html}))
      @reload!
    promises = <[html css js]>
      .map -> [it, d[it]]
      .filter -> it.1
      .map (n) ->
        if n.1 and n.1.url =>
          fetch n.1.url
            .then (v) ->
              if !(v and v.ok) => v.clone!text!then (t) -> e = new Error("#{v.status} #t") <<< {data: v}; throw e
              v.text!
            .then -> [n.0, it]
        else Promise.resolve [n.0, n.1]
    Promise.all promises
      .then (list) ~>
        d = {}
        list.map -> d[it.0] = it.1
        @load(
          """
          #{d.html or ''}
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

