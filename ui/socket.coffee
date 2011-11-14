window.WebSocket or= MozWebSocket

window.socket = new WebSocket($('body').attr('data-socket-url'));

eventMap = {}

window.bindEvent = (event, callback) ->
    eventMap[event] or= []
    eventMap[event].push callback

window.socket.onmessage = (msg) ->
    event = $.parseJSON(msg.data)
    console.log("EVENT", event)
    if callbacks = eventMap[event.event]
        $(callbacks).each (i, cb) -> cb(event.data)

window.callAction = (controller, action, args...) ->
    message = JSON.stringify(
        controller: controller
        action: action
        arguments: args
    )
    window.socket.send(message)
