
window.connectWidget = ->
  widget = div('connect-widget')

  hide = ->
    widget.animate
      'margin-top': - widget.outerHeight()

  loginForm = div('form')
  jidInput = input('jid', 'text', window.urlParam('jid'))
  connectButton = button("Connect")
  connectButton.click ->
    callAction('main', 'connect', jidInput.val())
  bindEvent 'connecting', (evt) ->
    log(logTarget, "Connecting " + evt.jid + "...")
  bindEvent 'auth_params', (evt) ->
    mechs = ''
    for mech, params of evt.params
      mechs += ' ' + mech
      authForm = form()
      authForm.append(text("Mechanism: " + mech))
      for key, l of params
        row = div('row')
        row.append(label(key, l))
        row.append(input(key, 'password'))
        authForm.append(row)
      authForm.append(submit("Authenticate"))
      loginForm.append(authForm)
      authForm.submit ->
        try
          callAction 'main', 'auth',
            mechanism: mech
            params: authForm.serializeObject()
        catch exc
          console.log(exc)
        return false
    log(logTarget, "Authentication Mechanisms: " + mechs)

  bindEvent 'tls_negotiated', (evt) ->
    log(logTarget, "TLS negotiated - connection secure.")
  bindEvent 'auth_success', (evt) ->
    hide()
  bindEvent 'auth_failure', (evt) ->
    log(logTarget, evt.message)

  loginForm.append(label('jid', 'JID'))
  loginForm.append(jidInput)
  loginForm.append(connectButton)
  widget.append(loginForm)
  return widget
