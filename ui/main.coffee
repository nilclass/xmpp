
window.require = (name) ->
  $('head').append('<script src="' + "/" + name + '.js"></script')

$(document).ready ->
  require 'helpers'
  require 'socket'
  require 'connectWidget'

$(document).ready ->

  container = div('#container')

  window.logTarget = div('#log')
  container.append(logTarget)


  bindEvent 'exception', (exc) ->
    alert exc.message
    log(logTarget, exc.message, exc['class'])
    log(logTarget, exc.backtrace)

  bindEvent 'bound', (evt) ->
    log(logTarget, "Bound as: " + evt.jid)

  bindEvent 'ready', (evt) ->
    log(logTarget, "READY!")

  container.append(connectWidget())
  $(document.body).append(container)
