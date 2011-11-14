
window.require = (name) ->
    $('head').append('<script src="' + "/" + name + '.js"></script')

$(document).ready ->
    require 'helpers'
    require 'socket'
    require 'connectWidget'

$(document).ready ->

    bindEvent 'exception', (exc) ->
        alert exc.message

    container = div('#container')
    container.append(connectWidget())
    $(document.body).append(container)
