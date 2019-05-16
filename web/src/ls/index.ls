sb = new Sandbox root: \iframe

func-test = ->
  console.log "[Load] string: 'hello world'"
  sb.load "Text load from string ( sandbox.load '...' ) OK"
    .then -> debounce 2000
    .then ->
      console.log "[Load] object with string"
      config = do
        html: "<html><head></head><body> Load HTML,JS and CSS from Object... <span></span></body></html>"
        js: """
        console.log("[In Sandbox] loaded from object string");
        document.querySelector("span").innerText = "JS Load OK."
        """
        css: '''
        html,body { background: #f00; }
        span:before { content: "CSS Load OK."; display: block; }
        '''
      sb.load config
    .then -> debounce 2000
    .then ->
      console.log "[Load] object with URL"
      sb.load html: {url: "/sandbox.html"}
    .then -> debounce 2000
    .then ->
      console.log "[Load] Reload"
      new Promise (res, rej) ->
        setTimeout (-> sb.reload!then -> res! ), 2000
    .then ->
      sb.set-proxy {Interface}
      sb.proxy.func!
    .then ->
      console.log "test completed."

textarea = ld$.find document, \textarea, 0
textarea.addEventListener \keyup, debounce -> sb.load textarea.value
sb.load textarea.value
