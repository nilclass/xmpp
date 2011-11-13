
window.require = (name) ->
    tag = document.createElement('script')
    tag.setAttribute('src', "/" + name + ".js")
    tag.setAttribute('type', 'text/javascript')
    head = document.getElementsByTagName('head')[0]
    head.appendChild(tag)

$(document).ready ->

    window.WebSocket or= MozWebSocket

    window.socket = new WebSocket($('body').attr('data-socket-url'));

    eventMap = {}

    window.bindEvent = (event, callback) ->
        eventMap[event] or= []
        eventMap[event].push callback

    window.socket.onmessage = (msg) ->
        event = $.parseJSON(msg.data)
        console.log(event)
        if callbacks = eventMap[event.event]
            $(callbacks).each (i, cb) -> cb(event.data)

    callAction = (controller, action, args...) ->
        message = JSON.stringify(
            controller: controller
            action: action
            arguments: args
        )
        window.socket.send(message)

    bindEvent 'exception', (exc) ->
        alert exc.message

    ## HELPER
    div = (classes...) ->
        if match = classes[0].match(/^\#(\w+)/)
            classes.pop()
            add = ' id="'+match[1]+'"'
        $('<div class="' +
            classes.join(' ') +
            '"' + (add || '') + '></div>')
    input = (name, type) ->
        type or= 'text'
        $('<input name="' + name + '" type="' + type + '">')
    button = (value) ->
        $('<button>' + value + '</button>')

    connectWidget = ->
        widget = div('connect-widget')
        form = div('form')
        jidInput = input('jid')
        connectButton = button("Connect")
        connectButton.click ->
            callAction('main', 'connect', jidInput.val())
        info = div('info')
        bindEvent 'connecting', (evt) ->
            info.html("Connecting " + evt.jid + "...")
        bindEvent 'auth_params', (evt) ->
            info.html("Please Authenticate: ")
            console.log('params', evt.params)

        form.append(jidInput)
        form.append(connectButton)
        form.append(info)
        widget.append(form)
        return widget

    container = div('#container')
    container.append(connectWidget())
    $(document.body).append(container)
