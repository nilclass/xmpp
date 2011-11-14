
window.connectWidget = ->
    widget = div('connect-widget')
    form = div('form')
    jidInput = input('jid', 'text', window.urlParam('jid'))
    connectButton = button("Connect")
    connectButton.click ->
        callAction('main', 'connect', jidInput.val())
    info = div('info')
    bindEvent 'connecting', (evt) ->
        log(info, "Connecting " + evt.jid + "...")
    bindEvent 'auth_params', (evt) ->
        log(info, "Please Authenticate.")
    bindEvent 'auth_failure', (evt) ->
        log(info, evt.message)

    form.append(label('jid', 'JID'))
    form.append(jidInput)
    form.append(connectButton)
    widget.append(info)
    widget.append(form)
    return widget
