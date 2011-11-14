
window.urlParam = (name) ->
	results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
	return if results then results[1] else null


window.div = (classes...) ->
    if match = classes[0].match(/^\#(\w+)/)
        classes.pop()
        add = ' id="'+match[1]+'"'
    $('<div class="' +
        classes.join(' ') +
        '"' + (add || '') + '></div>')

window.input = (name, type, value) ->
    type or= 'text'
    $('<input id="' + name + '" name="' +
        name + '" type="' + type + '"' +
        ' value="' + (value || '') + '">')

window.form = ->
  $('<form></form>')

window.submit = (value) ->
  window.input('', 'submit', value)

window.button = (value) ->
    $('<button>' + value + '</button>')

window.label = (name, value) ->
    $('<label for="' + name + '">' + value + '</label>')

window.text = (text) ->
    $('<div title="' + text + '">' + text + "</div>")

window.log = (target, message) ->
        target.append(text(message))

$.fn.extend
  serializeObject: ->
    object = {}
    object[i.name] = i.value for i in this.serializeArray()
    return object