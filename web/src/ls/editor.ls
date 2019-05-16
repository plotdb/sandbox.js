handler = (e) ->
  console.log "[editor] incoming message: ", e
window.addEventListener \message, handler, false
console.log "editor loaded."
