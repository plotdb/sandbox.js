handler = (e) -> console.log "[sandbox] incoming message: ", e
window.addEventListener \message, handler, false
console.log "sandbox JS load OK."
span = document.querySelector("span")
span.innerText = "sandbox JS load OK."
