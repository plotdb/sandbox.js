sb = new Sandbox root: \iframe

console.log "[Load] string: 'hello world'"
sb.load "hello world!"
  .then -> debounce 2000
  .then ->
    console.log "[Load] object with string"
    config = do
      html: "<html><head></head><body> Hello </body></html>"
      js: """console.log("[In Sandbox] loaded from string");"""
      css: '''html,body { background: #f00; }'''
    sb.load config
  .then -> debounce 2000
  .then ->
    console.log "[Load] object with url"
    sb.load html: {url: "/editor.html"}
  .then -> debounce 2000
  .then ->
    console.log "[Load] Reload"
    new Promise (res, rej) ->
      setTimeout (-> sb.reload!then -> res! ), 2000
  .then ->
    console.log "test completed."
    sb.set-proxy {Interface}
    sb.proxy.blah!
